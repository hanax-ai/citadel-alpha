#!/bin/bash
# scripts/management/voice_test.sh

set -e

source /home/agent0/citadel-alpha-supercharged/config/environment/.env.production
cd /home/agent0/citadel-alpha-supercharged
source venv/bin/activate

echo "🎙️ Citadel Alpha Supercharged Voice System Test"
echo "================================================"

# Check voice services
echo "📊 Voice Service Status:"
voice_services=("citadel-livekit" "citadel-voice@jarvis")

for service in "${voice_services[@]}"; do
    if systemctl is-active --quiet $service.service; then
        echo "  ✅ $service: Active"
    else
        echo "  ❌ $service: Inactive"
    fi
done

echo ""

# Check voice API endpoints
echo "🌐 Voice API Endpoints:"
voice_endpoints=(
    "http://localhost:$VOICE_ROUTER_PORT/health:Voice Router"
    "http://localhost:$VOICE_ROUTER_PORT/voice/agents:Voice Agents"
    "http://localhost:$VOICE_ROUTER_PORT/voice/status:Voice Status"
)

for endpoint in "${voice_endpoints[@]}"; do
    url=$(echo $endpoint | cut -d: -f1)
    name=$(echo $endpoint | cut -d: -f2)
    
    if curl -s --max-time 5 $url > /dev/null; then
        echo "  ✅ $name: Responding"
    else
        echo "  ❌ $name: Not responding"
    fi
done

echo ""

# Test voice processing pipeline
echo "🎤 Voice Processing Pipeline:"
if python -c "
from src.voice.processors.stt_processor import STTProcessor
from src.voice.processors.tts_processor import TTSProcessor
from src.voice.processors.vad_processor import VADProcessor

try:
    stt = STTProcessor()
    print('  ✅ STT Processor: Ready')
except Exception as e:
    print(f'  ❌ STT Processor: {e}')

try:
    tts = TTSProcessor()
    print('  ✅ TTS Processor: Ready')
except Exception as e:
    print(f'  ❌ TTS Processor: {e}')

try:
    vad = VADProcessor()
    print('  ✅ VAD Processor: Ready')
except Exception as e:
    print(f'  ❌ VAD Processor: {e}')
"; then
    :
fi

echo ""

# Test LiveKit connection
echo "📡 LiveKit Connection:"
if python -c "
from src.services.livekit_service import LiveKitService
try:
    service = LiveKitService()
    service.test_connection()
    print('  ✅ LiveKit: Connected')
except Exception as e:
    print(f'  ❌ LiveKit: {e}')
"; then
    :
fi

echo ""

# Test voice agent availability
echo "🤖 Voice Agents:"
if python -c "
from src.voice.agents.jarvis_agent import JarvisAgent
try:
    agent = JarvisAgent()
    print('  ✅ Jarvis Agent: Available')
except Exception as e:
    print(f'  ❌ Jarvis Agent: {e}')
"; then
    :
fi

echo ""

# Check audio devices
echo "🔊 Audio Devices:"
if command -v arecord &> /dev/null; then
    echo "  📥 Input devices:"
    arecord -l | grep "card" | head -3 | sed 's/^/    /'
    echo "  📤 Output devices:"
    aplay -l | grep "card" | head -3 | sed 's/^/    /'
else
    echo "  ❌ Audio tools not available"
fi

echo ""

# Voice system performance
echo "⚡ Voice System Performance:"
echo "  🎙️ Voice processing: $(python -c "import time; start=time.time(); from src.voice.processors.stt_processor import STTProcessor; print(f'{(time.time()-start)*1000:.0f}ms')")"
echo "  🔊 TTS processing: $(python -c "import time; start=time.time(); from src.voice.processors.tts_processor import TTSProcessor; print(f'{(time.time()-start)*1000:.0f}ms')")"

echo ""
echo "🎯 Voice system test completed"
echo ""
echo "💡 To test voice interaction:"
echo "  curl -X POST http://localhost:$VOICE_ROUTER_PORT/voice/start-session"
echo "  curl -X POST http://localhost:$VOICE_ROUTER_PORT/voice/test-agent -d '{\"message\":\"Hello Jarvis\"}'"
