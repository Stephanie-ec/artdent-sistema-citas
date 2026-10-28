const fs = require('fs');

async function getPageWsUrl() {
    const res = await fetch('http://127.0.0.1:9222/json');
    const tabs = await res.json();
    const pageTab = tabs.find(t => t.type === 'page' && t.url.includes('ArtDent')) || tabs.find(t => t.type === 'page');
    return pageTab.webSocketDebuggerUrl;
}

function sendCommand(ws, id, method, params = {}) {
    return new Promise((resolve) => {
        const handler = (event) => {
            const data = JSON.parse(event.data);
            if (data.id === id) {
                ws.removeEventListener('message', handler);
                resolve(data.result);
            }
        };
        ws.addEventListener('message', handler);
        ws.send(JSON.stringify({ id, method, params }));
    });
}

async function run() {
    // First, lock user 78223344 via mysql command
    const { execSync } = require('child_process');
    execSync("mysql -u root -prootroot db_artdent_apf2 -e \"UPDATE Usuario SET IntentosFallidos = 5, BloqueadoHasta = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE DNI = '78223344';\"");

    const wsUrl = await getPageWsUrl();
    const ws = new WebSocket(wsUrl);

    await new Promise(r => ws.onopen = r);
    let msgId = 1;

    // Enable Page & Runtime
    await sendCommand(ws, msgId++, 'Page.enable');
    await sendCommand(ws, msgId++, 'Runtime.enable');

    // Navigate to iniciosesionerror.jsp via POST simulation or direct test
    // To see the real dynamic render from controller, let's submit credentials via fetch inside browser
    console.log("Submitting login request to controller from browser...");
    const navPromise = new Promise(resolve => {
        const loadHandler = (event) => {
            const data = JSON.parse(event.data);
            if (data.method === 'Page.loadEventFired') {
                ws.removeEventListener('message', loadHandler);
                resolve();
            }
        };
        ws.addEventListener('message', loadHandler);
    });

    // Navigate to login page
    await sendCommand(ws, msgId++, 'Page.navigate', { url: 'http://localhost:8080/ArtDent/iniciosesion.jsp' });
    await navPromise;

    // Fill inputs and submit form in the browser
    const submitNavPromise = new Promise(resolve => {
        const loadHandler = (event) => {
            const data = JSON.parse(event.data);
            if (data.method === 'Page.loadEventFired') {
                ws.removeEventListener('message', loadHandler);
                resolve();
            }
        };
        ws.addEventListener('message', loadHandler);
    });

    await sendCommand(ws, msgId++, 'Runtime.evaluate', {
        expression: `
            document.getElementById('document').value = '78223344';
            document.getElementById('password').value = 'wrongpassword';
            document.querySelector('form').submit();
        `
    });

    await submitNavPromise;
    await new Promise(r => setTimeout(r, 1000));

    // Capture screenshot of the lockout error page
    const screenshotRes = await sendCommand(ws, msgId++, 'Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync('login_bloqueado_ui.png', Buffer.from(screenshotRes.data, 'base64'));
    console.log("Saved login_bloqueado_ui.png successfully!");

    // Clean up lockout for secretary
    execSync("mysql -u root -prootroot db_artdent_apf2 -e \"UPDATE Usuario SET IntentosFallidos = 0, BloqueadoHasta = NULL WHERE DNI = '78223344';\"");
    ws.close();
}

run().catch(console.error);
