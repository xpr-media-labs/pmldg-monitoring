# PMLDG Monitoring

Sistem izleme, metrik toplama ve alarm yönetimi servisi.

## 🎯 Özellikler

- **Real-time Metrics**: Canlı sistem metrikleri
- **Custom Dashboards**: Grafana dashboards
- **Alert Management**: Prometheus alerting
- **Log Aggregation**: Merkezi log toplama
- **Performance Tracking**: Performans analizi
- **Health Checks**: Servis durumu kontrolü
- **Distributed Tracing**: Request tracking

## 🔧 Teknolojiler

- Prometheus (Metrics collection)
- Grafana (Visualization)
- Winston (Logging)
- Jaeger (Tracing)
- Node.js Exporter
- Alert Manager

## 🌐 URL

- Production: https://monitor.gateway.paribu.media
- Development: http://localhost:3007
- Grafana: https://monitor.gateway.paribu.media/grafana
- Prometheus: https://monitor.gateway.paribu.media/prometheus

## 📊 Monitored Metrics

### System Metrics
```
- CPU Usage
- Memory Usage
- Disk I/O
- Network Traffic
- Container Status
```

### Application Metrics
```
- Request Rate (RPS)
- Response Time (Latency)
- Error Rate
- Database Connection Pool
- Cache Hit Ratio
```

### Business Metrics
```
- Sensor Data Ingestion Rate
- API Key Usage
- Active Users
- Data Storage Growth
- Protocol Usage Distribution
```

## 📁 Klasör Yapısı

```
prometheus/
├── prometheus.yml       # Prometheus configuration
├── rules/              # Alerting rules
├── targets/            # Service discovery
└── alerts/             # Alert definitions

grafana/
├── dashboards/         # JSON dashboards
├── datasources/        # Data source configs
├── provisioning/       # Auto-provisioning
└── plugins/            # Custom plugins

logging/
├── winston.config.js   # Log configuration
├── formatters/         # Log formatters
├── transports/         # Log destinations
└── filters/            # Log filtering

jaeger/
├── jaeger.yml          # Tracing configuration
├── sampling/           # Sampling strategies
└── storage/            # Trace storage config

src/
├── collectors/         # Custom metric collectors
├── exporters/          # Prometheus exporters
├── alerts/             # Alert handlers
└── dashboards/         # Dashboard generators
```

## 🚀 Çalıştırma

```bash
# Docker Compose ile tüm monitoring stack
docker-compose up -d

# Sadece Prometheus
docker-compose up prometheus

# Sadece Grafana
docker-compose up grafana
```

## 📈 Dashboard'lar

### 1. System Overview
- Tüm servislerin genel durumu
- Resource utilization
- Request/response patterns
- Error rates

### 2. Sensor Data Pipeline
- Data ingestion rate
- Processing latency
- Queue depths
- Data quality metrics

### 3. API Performance
- Endpoint response times
- Throughput by protocol
- Authentication success rates
- Rate limiting status

### 4. Infrastructure Health
- Container status
- Database performance
- Cache performance
- Network connectivity

## 🚨 Alert Rules

### Critical Alerts
```yaml
# High error rate
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"

# Database connection issues
- alert: DatabaseDown
  expr: up{job="database"} == 0
  for: 1m
  labels:
    severity: critical

# Disk space low
- alert: DiskSpaceLow
  expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
  for: 5m
  labels:
    severity: warning
```

### Performance Alerts
```yaml
# High response time
- alert: HighResponseTime
  expr: http_request_duration_seconds{quantile="0.95"} > 1
  for: 5m
  labels:
    severity: warning

# Memory usage high
- alert: HighMemoryUsage
  expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
  for: 5m
  labels:
    severity: warning
```

## 💡 Custom Metrics

### Application Metrics (Node.js)
```javascript
const promClient = require('prom-client');

// Custom metrics
const sensorDataRate = new promClient.Counter({
  name: 'sensor_data_total',
  help: 'Total number of sensor data points received',
  labelNames: ['sensor_type', 'sensor_id']
});

const apiKeyUsage = new promClient.Counter({
  name: 'api_key_usage_total',
  help: 'Total API key usage by key',
  labelNames: ['api_key_id', 'endpoint']
});

const dataProcessingDuration = new promClient.Histogram({
  name: 'data_processing_duration_seconds',
  help: 'Time spent processing sensor data',
  labelNames: ['processing_type'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1]
});

// Usage
sensorDataRate.inc({ sensor_type: 'temperature', sensor_id: 'temp-01' });
apiKeyUsage.inc({ api_key_id: 'key-123', endpoint: '/api/sensors' });

const endProcessingTimer = dataProcessingDuration.startTimer({ processing_type: 'validation' });
// ... processing logic
endProcessingTimer();
```

### Custom Exporter
```javascript
const express = require('express');
const promClient = require('prom-client');

const app = express();
const register = new promClient.Registry();

// Register default metrics
promClient.collectDefaultMetrics({ register });

// Custom gauge
const activeConnections = new promClient.Gauge({
  name: 'pmldg_active_connections',
  help: 'Number of active connections by protocol',
  labelNames: ['protocol'],
  registers: [register]
});

// Update metrics
setInterval(() => {
  activeConnections.set({ protocol: 'socketio' }, getSocketIOConnections());
  activeConnections.set({ protocol: 'mqtt' }, getMQTTConnections());
  activeConnections.set({ protocol: 'webrtc' }, getWebRTCConnections());
}, 5000);

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(9090, () => {
  console.log('Metrics server listening on port 9090');
});
```

## 📧 Notification Channels

### Slack Integration
```yaml
# Alert Manager configuration
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#alerts'
    title: 'PMLDG Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

### Email Notifications
```yaml
- name: 'email-notifications'
  email_configs:
  - to: 'admin@paribu.com'
    from: 'alerts@paribu.media'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'alerts@paribu.media'
    auth_password: 'password'
    subject: 'PMLDG Alert: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
```
