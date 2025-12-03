import os
import json
import random
import anthropic

# ==============================================================================
# 1. Configuration
# ==============================================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DOC_DIR = os.path.join(PROJECT_ROOT, "DOC")
ETC_DIR = os.path.join(PROJECT_ROOT, "ETC")

# Categories to rotate through for diversity
TOPIC_CATEGORIES = [
    "Basic Combinational Logic (MUX, DEMUX, Encoder)",
    "Sequential Logic (Counters, Registers, FSM)",
    "Arithmetic Circuits (Adders, Multipliers, ALUs)",
    "Communication Protocols (SPI, I2C, UART, PS/2)",
    "Memory Controllers (FIFO, LIFO, RAM wrappers)",
    "DSP Building Blocks (Filters, CORDIC, PWM)",
    "Legacy 7400 Series Logic Chips implementation",
    "Digital Clock Managers (Dividers, Glitch-free muxes)"
]

# ==============================================================================
# 2. Helpers
# ==============================================================================
def load_api_key():
    key_file = os.path.join(ETC_DIR, "api-key.yml")
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key and os.path.exists(key_file):
        try:
            with open(key_file, 'r') as f:
                for line in f:
                    if "ANTHROPIC_API_KEY" in line:
                        parts = line.split(':', 1)
                        if len(parts) == 2:
                            api_key = parts[1].strip().strip('"').strip("'")
                            break
        except:
            pass
    if not api_key:
        raise ValueError("API Key not found.")
    return api_key

def get_existing_slugs():
    """Scans the DOC directory to find what we have already published."""
    if not os.path.exists(DOC_DIR):
        return set()

    existing = set()
    for f in os.listdir(DOC_DIR):
        if f.endswith(".md"):
            # remove extension to get slug
            existing.add(f[:-3])

    print(f"[Hunter] [INFO] Found {len(existing)} existing modules in library.")
    return existing

# ==============================================================================
# 3. Core Logic
# ==============================================================================
def hunt_new_topics(batch_size=5):
    """
    Generates a list of new, unique topics using Claude.
    """
    client = anthropic.Anthropic(api_key=load_api_key())
    existing_slugs = get_existing_slugs()

    # Pick a random category to focus on this time
    category = random.choice(TOPIC_CATEGORIES)
    print(f"[Hunter] [PLAN] Focusing on category: '{category}'")

    system_prompt = """
    You are a Project Manager for an FPGA Design Team.
    Your job is to list Verilog modules that need to be implemented.
    Output MUST be a valid JSON list of objects.
    Each object must have "topic" (human readable title) and "slug" (snake_case_filename).
    Do NOT include code, just the JSON data.
    """

    user_prompt = f"""
    Generate {batch_size + 3} unique Verilog module ideas related to category: "{category}".

    Constraint 1: The "slug" must be unique and descriptive.
    Constraint 2: Do NOT suggest these slugs (already done): {list(existing_slugs)}
    Constraint 3: Keep complexity suitable for a single module implementation.

    Example Output format:
    [
        {{"topic": "4-bit Ripple Carry Adder", "slug": "adder_4bit_ripple"}},
        {{"topic": " Synchronous FIFO 16-deep", "slug": "fifo_sync_16"}}
    ]
    """

    try:
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1000,
            temperature=0.7,
            system=system_prompt,
            messages=[{"role": "user", "content": user_prompt}]
        )

        # Parse JSON from response
        text = response.content[0].text
        # Find JSON array in text (in case of extra chatter)
        start = text.find('[')
        end = text.rfind(']') + 1

        if start == -1 or end == 0:
            print("[Hunter] [ERR] Could not find JSON in response.")
            return []

        json_str = text[start:end]
        candidates = json.loads(json_str)

        # Final Dedup Filter
        final_list = []
        for item in candidates:
            if item['slug'] not in existing_slugs:
                final_list.append(item)
                if len(final_list) >= batch_size:
                    break

        print(f"[Hunter] [DONE] Generated {len(final_list)} new topics.")
        return final_list

    except Exception as e:
        print(f"[Hunter] [ERR] Error generating topics: {e}")
        return []

if __name__ == "__main__":
    # Test run
    topics = hunt_new_topics(3)
    print(json.dumps(topics, indent=2))
