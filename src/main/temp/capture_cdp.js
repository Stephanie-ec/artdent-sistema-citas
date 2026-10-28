const fs = require('fs');

async function getPageWsUrl() {
    const res = await fetch('http://127.0.0.1:9222/json');
    const tabs = await res.json();
    const pageTab = tabs.find(t => t.type === 'page' && t.url.includes('ArtDent')) || tabs.find(t => t.type === 'page');
    if (!pageTab) throw new Error("No page tab found");
    return pageTab.webSocketDebuggerUrl;
}

function captureUrl(wsUrl, targetUrl, outputPath, delayMs = 1000) {
    return new Promise((resolve, reject) => {
        const ws = new WebSocket(wsUrl);
        let id = 1;

        ws.onopen = () => {
            // Enable Page
            ws.send(JSON.stringify({ id: id++, method: 'Page.enable' }));
            // Navigate
            ws.send(JSON.stringify({ id: id++, method: 'Page.navigate', params: { url: targetUrl } }));
        };

        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.method === 'Page.loadEventFired') {
                setTimeout(() => {
                    ws.send(JSON.stringify({ id: 999, method: 'Page.captureScreenshot', params: { format: 'png' } }));
                }, delayMs);
            }
            if (data.id === 999 && data.result && data.result.data) {
                const buffer = Buffer.from(data.result.data, 'base64');
                fs.writeFileSync(outputPath, buffer);
                console.log(`Saved screenshot to ${outputPath}`);
                ws.close();
                resolve();
            }
        };

        ws.onerror = (err) => {
            reject(err);
        };
    });
}

async function main() {
    const targetUrl = process.argv[2] || 'http://localhost:8080/ArtDent/iniciosesion.jsp';
    const outputPath = process.argv[3] || 'screenshot.png';
    const delay = parseInt(process.argv[4] || '1000');
    
    const wsUrl = await getPageWsUrl();
    await captureUrl(wsUrl, targetUrl, outputPath, delay);
}

main().catch(err => {
    console.error("Error capturing screenshot:", err);
    process.exit(1);
});
