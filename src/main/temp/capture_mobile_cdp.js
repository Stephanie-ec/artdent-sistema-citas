const fs = require('fs');

async function getPageWsUrl() {
    const res = await fetch('http://127.0.0.1:9222/json');
    const tabs = await res.json();
    const pageTab = tabs.find(t => t.type === 'page' && t.url.includes('ArtDent')) || tabs.find(t => t.type === 'page');
    if (!pageTab) throw new Error("No page tab found");
    return pageTab.webSocketDebuggerUrl;
}

function captureMobile(wsUrl, targetUrl, outputPath, width = 390, height = 844) {
    return new Promise((resolve, reject) => {
        const ws = new WebSocket(wsUrl);
        let id = 1;

        ws.onopen = () => {
            ws.send(JSON.stringify({ id: id++, method: 'Page.enable' }));
            // Set device emulation
            ws.send(JSON.stringify({
                id: id++,
                method: 'Emulation.setDeviceMetricsOverride',
                params: {
                    width: width,
                    height: height,
                    deviceScaleFactor: 2,
                    mobile: true
                }
            }));
            // Navigate
            ws.send(JSON.stringify({ id: id++, method: 'Page.navigate', params: { url: targetUrl } }));
        };

        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.method === 'Page.loadEventFired') {
                setTimeout(() => {
                    ws.send(JSON.stringify({ id: 999, method: 'Page.captureScreenshot', params: { format: 'png' } }));
                }, 1200);
            }
            if (data.id === 999 && data.result && data.result.data) {
                const buffer = Buffer.from(data.result.data, 'base64');
                fs.writeFileSync(outputPath, buffer);
                console.log(`Saved mobile screenshot to ${outputPath}`);
                // Clear emulation
                ws.send(JSON.stringify({ id: id++, method: 'Emulation.clearDeviceMetricsOverride' }));
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
    const targetUrl = process.argv[2] || 'http://localhost:8080/ArtDent/reservapersonal.jsp';
    const outputPath = process.argv[3] || 'reserva_mobile_ui.png';
    const wsUrl = await getPageWsUrl();
    await captureMobile(wsUrl, targetUrl, outputPath);
}

main().catch(err => {
    console.error("Error capturing mobile screenshot:", err);
    process.exit(1);
});
