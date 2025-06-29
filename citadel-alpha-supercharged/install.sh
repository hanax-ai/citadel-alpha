#!/bin/bash
# install.sh - Complete Citadel Alpha Supercharged Installation

set -e

echo "🚀 Installing Citadel Alpha Supercharged AI Operating System with Voice AI..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root"
   echo "Run as a user with sudo privileges"
   exit 1
fi

# Load configuration
source config/environment/.env.production

echo "📋 Installation Configuration:"
echo "  Environment: $CITADEL_ENV"
echo "  Version: $CITADEL_VERSION"
echo "  Service User: $CITADEL_USER"
echo "  Database Server: $DB_HOST"
echo "  Voice Processing: $VOICE_PROCESSING_ENABLED"
echo "  LiveKit Integration: Enabled"
echo "  Proactor Integration: $PROACTOR_ENABLED"
echo "  AG-UI Integration: $AG_UI_ENABLED"
echo "  Auto-start: $AUTO_START_SERVICES"
echo ""

# Step 1: Install system dependencies
echo "📦 Installing system dependencies..."
sudo ./scripts/setup/install_dependencies.sh

# Step 2: Create service account
echo "👤 Creating service account: $CITADEL_USER"
sudo ./scripts/setup/create_user.sh

# Step 3: Setup Python environment
echo "🐍 Setting up Python environment..."
sudo -u $CITADEL_USER ./scripts/setup/setup_python.sh

# Step 4: Setup GPU and CUDA
echo "🎮 Setting up GPU and CUDA..."
sudo ./scripts/setup/setup_gpu.sh

# Step 5: Setup voice processing
echo "🎙️ Setting up voice processing..."
sudo -u $CITADEL_USER ./scripts/setup/setup_voice.sh

# Step 6: Setup LiveKit
echo "📡 Setting up LiveKit..."
sudo -u $CITADEL_USER ./scripts/setup/setup_livekit.sh

# Step 7: Configure services
echo "⚙️  Configuring services..."
sudo ./scripts/setup/setup_services.sh

# Step 8: Install systemd services
echo "🔧 Installing systemd services..."
sudo cp config/systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload

# Step 9: Enable auto-start services
if [[ "$AUTO_START_SERVICES" == "true" ]]; then
    echo "🔄 Enabling auto-start services..."
    sudo systemctl enable citadel-manager.service
    sudo systemctl enable citadel-router.service
    sudo systemctl enable citadel-monitor.service
    sudo systemctl enable citadel-livekit.service
    
    # Enable vLLM services for each model
    sudo systemctl enable citadel-vllm@phi3.service
    sudo systemctl enable citadel-vllm@deepcoder.service
    
    # Enable voice agents
    sudo systemctl enable citadel-voice@jarvis.service
fi

# Step 10: Set up database connection
echo "🗄️  Configuring database connection..."
sudo -u $CITADEL_USER python src/database/migrations.py

# Step 11: Download initial models
echo "🤖 Downloading initial AI models..."
sudo -u $CITADEL_USER ./scripts/maintenance/update_models.sh --initial

# Step 12: Validate installation
echo "✅ Validating installation..."
sudo -u $CITADEL_USER python src/config/validator.py

# Step 13: Start services
echo "🚀 Starting Citadel Alpha Supercharged services..."
sudo systemctl start citadel-manager.service

# Wait for services to start
sleep 45

# Step 14: Health check
echo "🏥 Running health check..."
sudo -u $CITADEL_USER ./scripts/management/health_check.sh

# Step 15: Voice system test
echo "🎙️ Testing voice system..."
sudo -u $CITADEL_USER ./scripts/management/voice_test.sh

echo ""
echo "🎉 Citadel Alpha Supercharged installation completed successfully!"
echo ""
echo "📊 Service Status:"
sudo systemctl status citadel-manager.service --no-pager -l
echo ""
echo "🌐 Access Points:"
echo "  Task Router: http://localhost:$ROUTER_PORT"
echo "  Voice Router: http://localhost:$VOICE_ROUTER_PORT"
echo "  Health Check: http://localhost:$ROUTER_PORT/health"
echo "  Voice Health: http://localhost:$VOICE_ROUTER_PORT/health"
echo "  Metrics: http://localhost:$METRICS_EXPORT_PORT/metrics"
echo ""
echo "🎙️ Voice AI Features:"
echo "  Jarvis AI Agent: Available via voice interface"
echo "  Proactor Voice Control: $PROACTOR_ENABLED"
echo "  AG-UI Voice Interface: $AG_UI_ENABLED"
echo "  LiveKit Integration: Active"
echo ""
echo "📚 Next Steps:"
echo "  1. Review logs: journalctl -u citadel-manager.service -f"
echo "  2. Test API: curl http://localhost:$ROUTER_PORT/health"
echo "  3. Test voice: curl -X POST http://localhost:$VOICE_ROUTER_PORT/voice/start-session"
echo "  4. View documentation: cat docs/README.md"
echo ""
echo "✅ Citadel Alpha Supercharged is ready for voice-enabled AI operations!"
