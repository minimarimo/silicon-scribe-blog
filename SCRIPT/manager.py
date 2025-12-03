import os
import subprocess
import re
import anthropic
import sys

# Add script directory to path to import trend_hunter
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_DIR)
import trend_hunter  # Import the new module

# ==============================================================================
# 1. Path Configuration
# ==============================================================================
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

RTL_DIR = os.path.join(PROJECT_ROOT, "RTL")
TB_DIR = os.path.join(PROJECT_ROOT, "TB")
SIM_DIR = os.path.join(PROJECT_ROOT, "SIM")
DOC_DIR = os.path.join(PROJECT_ROOT, "DOC")
ETC_DIR = os.path.join(PROJECT_ROOT, "ETC")
JUDGE_SCRIPT = os.path.join(SCRIPT_DIR, "judge_core.sh")
LOG_FILE = os.path.join(SIM_DIR, "sim_log.txt")

for d in [RTL_DIR, TB_DIR, SIM_DIR, DOC_DIR]:
    if not os.path.exists(d):
        os.makedirs(d)

# ==============================================================================
# 2. API Key Loading
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
                            print(f"[System] [KEY] Loaded API Key from {key_file}")
                            break
        except Exception as e:
            print(f"[System] [WARN] Error reading api-key.yml: {e}")

    if not api_key:
        raise ValueError("API Key not found in environment or ETC/api-key.yml")
    return api_key

try:
    client = anthropic.Anthropic(api_key=load_api_key())
except Exception as e:
    print(f"[System] [ERR] Critical Setup Error: {e}")
    exit(1)

# ==============================================================================
# 3. System Prompts
# ==============================================================================

# Engineer Persona
CODER_SYSTEM_PROMPT = """
You are an expert FPGA/ASIC Engineer in a team called 'Silicon Scribe'.
Your goal is to write synthesis-ready Verilog modules and robust self-checking Testbenches.

RULES:
1. You must provide TWO code blocks.
2. The first block must be the Design Module (Verilog).
3. The second block must be the Testbench (Verilog).
4. The Testbench MUST check the output automatically.
5. If the test passes, the Testbench MUST print exactly: "TEST PASSED" using $display().
6. If the test fails, it MUST print "TEST FAILED".
7. Do not use external libraries or UVM. Keep it simple SystemVerilog or Verilog-2001.
8. STRICTLY NO EMOTICONS or non-ASCII characters in the code. Use only standard ASCII.
"""

# Writer Persona
WRITER_SYSTEM_PROMPT = """
You are a Technical Writer for an Embedded Systems blog.
Your job is to take a verified Verilog module and write a high-quality, SEO-optimized blog post in Markdown.
The post should explain how the code works, the testbench logic, and real-world use cases.
DO NOT use emoticons in the blog post. Use standard ASCII formatting.
"""

# ==============================================================================
# 4. Core Functions
# ==============================================================================

def generate_verilog(topic):
    """Initial code generation"""
    print(f"[Manager] [GEN] Requesting code for: {topic}...")
    MODEL_ID = "claude-sonnet-4-20250514"

    response = client.messages.create(
        model=MODEL_ID,
        max_tokens=4000,
        temperature=0.2,
        system=CODER_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": f"Create a Verilog module and testbench for: {topic}"}]
    )
    return response.content[0].text

def refine_verilog(topic, original_code, error_log):
    """Ask AI to fix the code based on the error log"""
    print(f"[Manager] [FIX] Requesting fix for errors...")
    MODEL_ID = "claude-sonnet-4-20250514"

    refine_prompt = f"""
    The previous Verilog code for '{topic}' failed verification.

    --- PREVIOUS CODE ---
    {original_code}

    --- ERROR LOG ---
    {error_log}

    --- INSTRUCTIONS ---
    Analyze the error log. It indicates either a bug in the Design or a bug in the Testbench.
    Fix the code and provide the COMPLETE updated Design and Testbench.
    REMEMBER: No emoticons.
    """

    response = client.messages.create(
        model=MODEL_ID,
        max_tokens=4000,
        temperature=0.1,
        system=CODER_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": refine_prompt}]
    )
    return response.content[0].text

def generate_documentation(topic, verified_code, topic_slug):
    """
    Agent 4: Generates a technical blog post for the verified code.
    """
    print(f"[Manager] [DOC] Generating documentation for: {topic}...")
    MODEL_ID = "claude-sonnet-4-20250514"

    doc_prompt = f"""
    Write a technical blog post for the topic: "{topic}".

    --- VERIFIED CODE ---
    {verified_code}

    --- REQUIREMENTS ---
    1. Title: Engaging technical title.
    2. Introduction: What is this module and why is it useful?
    3. Code Analysis: Briefly explain the key logic in the Verilog code.
    4. Verification: Mention that this code has been automatically verified with a testbench.
    5. Usage: Example instantiation or real-world application.
    6. Format: Markdown.
    7. Constraint: Do NOT use emojis.
    """

    response = client.messages.create(
        model=MODEL_ID,
        max_tokens=4000,
        temperature=0.7,
        system=WRITER_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": doc_prompt}]
    )

    doc_content = response.content[0].text
    doc_filename = os.path.join(DOC_DIR, f"{topic_slug}.md")

    with open(doc_filename, "w") as f:
        f.write(doc_content)

    print(f"[Manager] [DOC] Saved: {doc_filename}")

def parse_and_save_files(ai_response, topic_slug):
    marker = "`" * 3
    pattern = marker + r"(?:verilog|systemverilog)?\n(.*?)" + marker
    code_blocks = re.findall(pattern, ai_response, re.DOTALL)

    if len(code_blocks) < 2:
        print("[Manager] [ERR] AI did not return two distinct code blocks.")
        return None, None

    design_code = code_blocks[0].strip()
    tb_code = code_blocks[1].strip()

    design_filename = os.path.join(RTL_DIR, f"{topic_slug}.v")
    tb_filename = os.path.join(TB_DIR, f"tb_{topic_slug}.v")

    with open(design_filename, "w") as f:
        f.write(design_code)
    with open(tb_filename, "w") as f:
        f.write(tb_code)

    print(f"[Manager] [SAVE] Saved Design & TB")
    return design_filename, tb_filename

def run_judge(design_file, tb_file):
    print("[Manager] [JUDGE] Summoning the Judge...")
    subprocess.run(["chmod", "+x", JUDGE_SCRIPT])

    abs_design = os.path.abspath(design_file)
    abs_tb = os.path.abspath(tb_file)
    abs_judge = os.path.abspath(JUDGE_SCRIPT)

    try:
        result = subprocess.run(
            [abs_judge, abs_design, abs_tb],
            cwd=SIM_DIR,
            capture_output=True,
            text=True
        )
        print(result.stdout.strip())
        return result.returncode == 0
    except Exception as e:
        print(f"[Manager] [ERR] Execution Error: {e}")
        return False

# ==============================================================================
# 5. Main Execution Flow (Auto-Subject Selection)
# ==============================================================================
if __name__ == "__main__":

    # 1. Ask Agent 1 (Trend Hunter) for new jobs
    BATCH_SIZE = 5
    print(f"[Factory] [INIT] Connecting to Trend Hunter to fetch {BATCH_SIZE} new orders...")

    try:
        TOPIC_LIST = trend_hunter.hunt_new_topics(BATCH_SIZE)
    except Exception as e:
        print(f"[Factory] [ERR] Failed to fetch topics: {e}")
        TOPIC_LIST = []

    if not TOPIC_LIST:
        print("[Factory] [STOP] No topics received. Exiting.")
        exit(0)

    MAX_RETRIES = 3

    print(f"[Factory] [START] Starting Mass Production for: {[t['slug'] for t in TOPIC_LIST]}")

    for idx, item in enumerate(TOPIC_LIST):
        topic = item["topic"]
        slug = item["slug"]

        print(f"\n========================================================")
        print(f"[JOB] {idx+1}/{len(TOPIC_LIST)}: {topic} ({slug})")
        print(f"========================================================")

        try:
            # 1. Initial Attempt
            current_response = generate_verilog(topic)

            job_success = False

            for attempt in range(MAX_RETRIES + 1):
                if attempt > 0:
                    print(f"   |-> [RETRY] Attempt {attempt}...")

                # 2. Parse & Save
                design_f, tb_f = parse_and_save_files(current_response, slug)

                if not design_f:
                    print("   [Manager] Parsing failed. Regenerating...")
                    current_response = generate_verilog(topic)
                    continue

                # 3. Validate
                success = run_judge(design_f, tb_f)

                if success:
                    print(f"   [Manager] [SUCCESS] Code verified.")

                    # 4. Publish
                    generate_documentation(topic, current_response, slug)
                    job_success = True
                    break
                else:
                    if attempt < MAX_RETRIES:
                        print(f"   [Manager] [FAIL] Verification Failed. Refining...")
                        if os.path.exists(LOG_FILE):
                            with open(LOG_FILE, 'r') as f:
                                error_log = f.read()
                        else:
                            error_log = "Log file not found."

                        current_response = refine_verilog(topic, current_response, error_log)
                    else:
                        print(f"   [Manager] [FAIL] Max retries reached. Moving to next ticket.")

            if job_success:
                print(f"[Factory] [DONE] Job '{slug}' completed.")
            else:
                print(f"[Factory] [SKIP] Job '{slug}' failed.")

        except KeyboardInterrupt:
            print("\n[Factory] [STOP] User interrupted the process.")
            break
        except Exception as e:
            print(f"[Factory] [ERR] Critical Error on job '{slug}': {e}")
            continue

    # Optional: Deploy after batch is done
    # subprocess.run(["./SCRIPT/deploy_agent.sh"])
    print(f"\n[Factory] [FINISH] All jobs processed.")
