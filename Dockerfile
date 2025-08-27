FROM grafana/grafana:latest

# Set environment variables
ENV GF_SECURITY_ADMIN_PASSWORD=admin123
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_SECURITY_ALLOW_EMBEDDING=true
ENV GF_AUTH_ANONYMOUS_ENABLED=true
ENV GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1
