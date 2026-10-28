import urllib.request
import time
import concurrent.futures

BASE_URL = "http://localhost:8080/ArtDent"

ENDPOINTS = [
    "/index.jsp",
    "/reservapersonal.jsp",
    "/iniciosesion.jsp",
    "/PagoController?action=verBoleta&idCita=1"
]

def fetch_url(endpoint):
    url = BASE_URL + endpoint
    t0 = time.time()
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 PerformanceBenchmark/1.0'})
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = resp.read()
            code = resp.getcode()
            elapsed_ms = (time.time() - t0) * 1000.0
            return {
                "endpoint": endpoint,
                "code": code,
                "size": len(data),
                "elapsed_ms": elapsed_ms,
                "success": (code == 200)
            }
    except Exception as e:
        elapsed_ms = (time.time() - t0) * 1000.0
        return {
            "endpoint": endpoint,
            "code": 500,
            "error": str(e),
            "elapsed_ms": elapsed_ms,
            "success": False
        }

def run_concurrency_test(total_requests=40, concurrency=10):
    print(f"=== Iniciando Prueba de Concurrencia RNF04 ({total_requests} reqs, concurrencia {concurrency}) ===")
    results = []
    
    # Task distribution across endpoints
    tasks = [ENDPOINTS[i % len(ENDPOINTS)] for i in range(total_requests)]
    
    t_start = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        futures = [executor.submit(fetch_url, ep) for ep in tasks]
        for f in concurrent.futures.as_completed(futures):
            results.append(f.result())
    t_total = time.time() - t_start
    
    successful = [r for r in results if r["success"]]
    times = [r["elapsed_ms"] for r in successful]
    
    avg_time = sum(times) / len(times) if times else 0
    min_time = min(times) if times else 0
    max_time = max(times) if times else 0
    p95_time = sorted(times)[int(len(times) * 0.95)] if times else 0
    throughput = len(results) / t_total if t_total > 0 else 0
    
    print(f"Total Requests: {len(results)}")
    print(f"Exitosos (HTTP 200): {len(successful)} / {len(results)} ({len(successful)/len(results)*100:.1f}%)")
    print(f"Tiempo Total de la prueba: {t_total:.3f} s")
    print(f"Throughput: {throughput:.1f} req/s")
    print(f"Latencia Mínima: {min_time:.2f} ms")
    print(f"Latencia Promedio: {avg_time:.2f} ms")
    print(f"Latencia Percentil 95 (P95): {p95_time:.2f} ms")
    print(f"Latencia Máxima: {max_time:.2f} ms")
    
    assert len(successful) == len(results), f"Fallaron {len(results) - len(successful)} solicitudes"
    assert avg_time < 1500.0, f"Latencia promedio ({avg_time:.2f} ms) excedió el límite de 1500 ms"
    assert p95_time < 1500.0, f"Latencia P95 ({p95_time:.2f} ms) excedió el límite de 1500 ms"
    print("\n>>> RESULTADO RNF04: Cumplimiento de Rendimiento y Concurrencia EXITOSO (100% OK) <<<")

if __name__ == "__main__":
    run_concurrency_test()
