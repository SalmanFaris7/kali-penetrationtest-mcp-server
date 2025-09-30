# Use Kali Linux as base image
FROM kalilinux/kali-rolling:latest

# Set working directory
WORKDIR /app

# Set Python unbuffered mode
ENV PYTHONUNBUFFERED=1

# Update and install required tools and Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    nmap \
    nikto \
    sqlmap \
    wpscan \
    dirb \
    exploitdb \
    net-tools \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Copy the server code
COPY kali_pentest_server.py .

# Create non-root user with proper groups for network tools
RUN useradd -m -u 1000 mcpuser && \
    usermod -aG sudo mcpuser && \
    chown -R mcpuser:mcpuser /app

# Set capabilities for network tools (must be done as root)
RUN setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap && \
    setcap cap_net_raw,cap_net_admin+eip /usr/bin/ping || true

# Switch to non-root user
USER mcpuser

# Run the server
CMD ["python3", "kali_pentest_server.py"]