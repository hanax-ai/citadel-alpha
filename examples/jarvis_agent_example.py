"""
Jarvis Agent Example - Advanced voice AI assistant

This example demonstrates how to create and run a Jarvis AI agent
with voice capabilities for business process automation.
"""

from livekit.agents import (
    Agent,
    AgentSession,
    JobContext,
    RunContext,
    WorkerOptions,
    cli,
    function_tool,
)
from livekit.plugins import deepgram, elevenlabs, openai, silero
import asyncio
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@function_tool
async def start_business_process(
    context: RunContext,
    process_name: str,
    entity: str,
):
    """Start a business process for a specific entity"""
    logger.info(f"Starting business process: {process_name} for {entity}")
    
    # This would integrate with your Proactor system
    return {
        "status": "initiated",
        "process": process_name,
        "entity": entity,
        "message": f"Successfully started {process_name} process for {entity}"
    }

@function_tool
async def check_system_status(
    context: RunContext,
    component: str = "all",
):
    """Check the status of system components"""
    logger.info(f"Checking system status for: {component}")
    
    # This would check actual system status
    return {
        "status": "healthy",
        "component": component,
        "uptime": "99.9%",
        "message": f"System component '{component}' is operating normally"
    }

@function_tool
async def generate_report(
    context: RunContext,
    report_type: str,
    period: str = "last_week",
):
    """Generate business reports"""
    logger.info(f"Generating {report_type} report for {period}")
    
    # This would generate actual reports
    return {
        "status": "completed",
        "report_type": report_type,
        "period": period,
        "message": f"Generated {report_type} report for {period}"
    }

async def entrypoint(ctx: JobContext):
    """Main entry point for the Jarvis agent"""
    await ctx.connect()
    
    # Create the Jarvis agent with business capabilities
    agent = Agent(
        instructions="""
        You are Jarvis, an advanced AI assistant for Citadel Alpha Supercharged.
        
        You can help with:
        - Starting and managing business processes
        - Checking system status and health
        - Generating business reports
        - Providing guidance and support
        
        Always be professional, helpful, and proactive in offering assistance.
        When users make requests, confirm the details before taking action.
        """,
        tools=[start_business_process, check_system_status, generate_report],
    )
    
    # Create the agent session with voice capabilities
    session = AgentSession(
        vad=silero.VAD.load(),
        stt=deepgram.STT(model="nova-3"),
        llm=openai.LLM(model="gpt-4o-mini"),
        tts=elevenlabs.TTS(),
    )
    
    # Start the session
    await session.start(agent=agent, room=ctx.room)
    
    # Initial greeting
    await session.generate_reply(
        instructions="""
        Greet the user as Jarvis and introduce your capabilities.
        Ask how you can assist with their business needs today.
        """
    )

if __name__ == "__main__":
    # Run the agent
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))
