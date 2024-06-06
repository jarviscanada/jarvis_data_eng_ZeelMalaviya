
\c host_agent

CREATE TABLE IF NOT EXISTS host_info (
    id SERIAL PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL,
    cpu_number INT NOT NULL,
    cpu_architecture VARCHAR(50) NOT NULL,
    cpu_model VARCHAR(255) NOT NULL,
    cpu_mhz REAL NOT NULL,
    l2_cache_kb INT NOT NULL,
    total_mem INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS host_usage (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    host_id INT NOT NULL,
    memory_free INT NOT NULL,
    cpu_idle REAL NOT NULL,
    cpu_kernel REAL NOT NULL,
    disk_io INT NOT NULL,
    disk_available INT NOT NULL,
    FOREIGN KEY (host_id) REFERENCES host_info(id)
);

