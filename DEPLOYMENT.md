# Deployment Guide

## Overview

This guide covers different deployment options for the Family Dinner Tracker application, from local development to production deployment.

## Prerequisites

All deployment methods require:
- R (>= 4.0.0)
- Required R packages (see DESCRIPTION)
- Quarto CLI (optional but recommended)

## Option 1: Local Development (Recommended for Getting Started)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/mleary/family-dinner.git
   cd family-dinner
   ```

2. **Install R packages**
   ```r
   install.packages(c("shiny", "DT", "dplyr", "lubridate", "RSQLite", "quarto"))
   ```

3. **Initialize sample data (optional)**
   ```r
   source("init_sample_data.R")
   ```

4. **Run the app**
   ```r
   shiny::runApp("app.R")
   ```
   Or use the convenience script:
   ```r
   source("run.R")
   ```

### Access
- The app will open in your default browser
- Default URL: `http://127.0.0.1:####` (port varies)
- Press `Ctrl+C` in R console to stop

### Advantages
- ✅ Quick to set up
- ✅ No server configuration needed
- ✅ Full control over data
- ✅ Easy debugging

### Limitations
- ❌ Only accessible on your computer
- ❌ Requires R to be running
- ❌ Not accessible to remote family members

## Option 2: Local Network Deployment

Share the app with family members on your home network.

### Setup

1. Find your local IP address:
   - **Windows**: `ipconfig`
   - **Mac/Linux**: `ifconfig` or `ip addr`
   - Look for something like `192.168.1.X`

2. Run the app on a specific port and host:
   ```r
   shiny::runApp("app.R", host = "0.0.0.0", port = 3838)
   ```

3. Share the URL with family:
   ```
   http://YOUR_LOCAL_IP:3838
   ```
   Example: `http://192.168.1.100:3838`

### Advantages
- ✅ Accessible to everyone on your network
- ✅ Still local and private
- ✅ No external dependencies

### Limitations
- ❌ Only works on home network
- ❌ Requires your computer to be running
- ❌ Not accessible when away from home

## Option 3: Shiny Server (Self-Hosted)

Host the app on a dedicated server for 24/7 access.

### Requirements
- Linux server (Ubuntu recommended)
- Root access
- Static IP or domain name

### Installation

1. **Install R**
   ```bash
   sudo apt update
   sudo apt install r-base r-base-dev
   ```

2. **Install required R packages**
   ```bash
   sudo R
   ```
   ```r
   install.packages(c("shiny", "DT", "dplyr", "lubridate", "RSQLite", "quarto"))
   ```

3. **Install Shiny Server**
   ```bash
   sudo apt-get install gdebi-core
   wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
   sudo gdebi shiny-server-1.5.20.1002-amd64.deb
   ```

4. **Copy app files**
   ```bash
   sudo mkdir -p /srv/shiny-server/family-dinner
   sudo cp -r /path/to/app/* /srv/shiny-server/family-dinner/
   sudo chown -R shiny:shiny /srv/shiny-server/family-dinner
   ```

5. **Configure Shiny Server**
   Edit `/etc/shiny-server/shiny-server.conf`:
   ```
   run_as shiny;
   server {
     listen 3838;
     location /family-dinner {
       app_dir /srv/shiny-server/family-dinner;
       log_dir /var/log/shiny-server/family-dinner;
     }
   }
   ```

6. **Restart Shiny Server**
   ```bash
   sudo systemctl restart shiny-server
   ```

7. **Access the app**
   ```
   http://your-server-ip:3838/family-dinner
   ```

### Advantages
- ✅ 24/7 availability
- ✅ Full control over server
- ✅ Can use custom domain
- ✅ No per-user costs

### Limitations
- ❌ Requires server management
- ❌ Need to handle backups
- ❌ Must secure the server
- ❌ Requires technical knowledge

## Option 4: shinyapps.io (Cloud Hosted)

Deploy to RStudio's cloud platform for easy hosting.

### Setup

1. **Create account**
   - Go to https://www.shinyapps.io/
   - Sign up for free account (25 active hours/month free tier)

2. **Install rsconnect**
   ```r
   install.packages("rsconnect")
   ```

3. **Configure authentication**
   - Log into shinyapps.io
   - Go to Account > Tokens
   - Click "Show" and copy the token
   - Run the command shown (something like):
   ```r
   rsconnect::setAccountInfo(
     name='your-account-name',
     token='your-token',
     secret='your-secret'
   )
   ```

4. **Deploy the app**
   ```r
   rsconnect::deployApp(appDir = "/path/to/family-dinner")
   ```

5. **Access the app**
   - URL will be: `https://your-account.shinyapps.io/family-dinner/`

### Advantages
- ✅ Easy deployment
- ✅ No server management
- ✅ Automatic scaling
- ✅ HTTPS included
- ✅ Free tier available

### Limitations
- ❌ Limited hours on free tier
- ❌ Paid plans for more usage
- ❌ Data stored on RStudio servers
- ❌ Less customization

### Cost Considerations
- **Free**: 25 active hours/month, 5 apps
- **Starter**: $9/month, 100 active hours
- **Basic**: $39/month, 500 active hours
- **Standard**: $99/month, 2000 active hours

## Option 5: Docker Container

Package the app in a container for portable deployment.

### Dockerfile

Create `Dockerfile`:
```dockerfile
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'DT', 'dplyr', 'lubridate', 'RSQLite', 'quarto'))"

# Copy app files
COPY . /srv/shiny-server/family-dinner/

# Make sure database directory is writable
RUN mkdir -p /srv/shiny-server/family-dinner/data && \
    chown -R shiny:shiny /srv/shiny-server/family-dinner

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

### Build and Run

```bash
# Build image
docker build -t family-dinner .

# Run container
docker run -d -p 3838:3838 \
  -v $(pwd)/data:/srv/shiny-server/family-dinner/data \
  --name family-dinner \
  family-dinner

# Access at http://localhost:3838/family-dinner
```

### Docker Compose

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3838:3838"
    volumes:
      - ./data:/srv/shiny-server/family-dinner/data
    restart: unless-stopped
```

Run with:
```bash
docker-compose up -d
```

### Advantages
- ✅ Consistent environment
- ✅ Easy to move between systems
- ✅ Isolated from host system
- ✅ Version control for entire stack

### Limitations
- ❌ Requires Docker knowledge
- ❌ Additional complexity
- ❌ Resource overhead

## Option 6: RStudio Connect (Enterprise)

For organizations with RStudio Connect.

### Deployment

1. **Open the app in RStudio**
2. **Click "Publish" button**
3. **Select RStudio Connect**
4. **Follow prompts**

### Advantages
- ✅ Enterprise features
- ✅ User authentication
- ✅ Scheduled reports
- ✅ Usage analytics
- ✅ Professional support

### Limitations
- ❌ Enterprise pricing
- ❌ Requires RStudio Connect license
- ❌ Overkill for home use

## Security Considerations

### For Public Deployments

1. **Add Authentication**
   ```r
   # Using shinymanager
   install.packages("shinymanager")
   # Wrap UI with secure_app()
   ```

2. **Use HTTPS**
   - Get SSL certificate (Let's Encrypt)
   - Configure reverse proxy (nginx/Apache)

3. **Input Validation**
   - Already using `req()` for required fields
   - Consider adding more validation

4. **Rate Limiting**
   - Implement throttling for form submissions
   - Prevent abuse

5. **Database Security**
   - Move database outside web directory
   - Use proper file permissions
   - Consider encryption at rest

### For Private/Family Use

1. **Password Protection**
   ```r
   # Simple password prompt
   if (!exists("authenticated")) {
     password <- passwordInput("pw", "Password:")
     # Check against stored password
   }
   ```

2. **Network Restriction**
   - Use firewall rules
   - Whitelist IP addresses
   - VPN access only

## Data Backup

### Local Backup
```bash
# Backup database
cp dinner_data.db dinner_data_backup_$(date +%Y%m%d).db

# Automated backup (cron)
0 2 * * * cp /path/to/dinner_data.db /path/to/backups/dinner_data_$(date +\%Y\%m\%d).db
```

### Cloud Backup
```bash
# Upload to cloud storage
rclone copy dinner_data.db remote:backups/
```

## Monitoring

### Shiny Server Logs
```bash
# View logs
tail -f /var/log/shiny-server/family-dinner.log

# Check errors
grep ERROR /var/log/shiny-server/family-dinner.log
```

### Application Health
```bash
# Check if app is running
curl http://localhost:3838/family-dinner

# Monitor with uptime service
# - UptimeRobot
# - Pingdom
# - StatusCake
```

## Updating the Application

### Local Development
```bash
git pull origin main
# Restart the app
```

### Shiny Server
```bash
cd /srv/shiny-server/family-dinner
sudo git pull
sudo systemctl restart shiny-server
```

### shinyapps.io
```r
rsconnect::deployApp(appDir = "/path/to/family-dinner", forceUpdate = TRUE)
```

### Docker
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### App Won't Start
1. Check R version: `R --version`
2. Verify packages: `installed.packages()`
3. Check logs for errors
4. Verify file permissions

### Can't Connect Remotely
1. Check firewall rules
2. Verify port is open: `netstat -tuln | grep 3838`
3. Test with curl: `curl http://localhost:3838`
4. Check host setting (should be `0.0.0.0`)

### Database Errors
1. Check file permissions: `ls -l dinner_data.db`
2. Verify SQLite version: `sqlite3 --version`
3. Test database: `sqlite3 dinner_data.db "SELECT * FROM dinners;"`
4. Check for locks: `lsof dinner_data.db`

### Performance Issues
1. Check server resources: `htop`
2. Monitor R processes: `ps aux | grep R`
3. Check database size: `du -h dinner_data.db`
4. Review logs for errors

## Recommended Setup for Families

For most families, we recommend:

1. **Start with local development** to test the app
2. **Use local network deployment** for home access
3. **Consider shinyapps.io free tier** if you want remote access
4. **Upgrade to Shiny Server** if you have technical skills and want full control

The choice depends on:
- Technical comfort level
- Budget
- Need for remote access
- Number of users
- Privacy requirements

---

**Need help?** Open an issue on GitHub or consult the Shiny documentation.
