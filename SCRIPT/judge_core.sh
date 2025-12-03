#!/bin/bash

# ==============================================================================
# Script Name: judge_core.sh
# Description: Compiles and simulates Verilog/SystemVerilog
# Note: Designed to be run from inside the SIM/ directory by manager.py
# ==============================================================================

if [ "$#" -ne 2 ]; then
    echo "[System] Usage: $0 <design_file.v> <testbench_file.v>"
    exit 1
fi

DESIGN_FILE=$1
TB_FILE=$2
OUTPUT_BIN="sim_output.vvp"
LOG_FILE="sim_log.txt"

# Check iverilog
if ! command -v iverilog &> /dev/null; then
    echo "[System] Error: iverilog not installed."
    exit 1
fi

echo "========================================="
echo "[System] Starting Verification..."
echo "[Input] Design: $DESIGN_FILE"
echo "[Input] TB:     $TB_FILE"
echo "[Info]  CWD:    $(pwd)"

# 1. Compile
# iverilog가 include 파일을 찾을 수 있도록 RTL 폴더를 include path(-I)에 추가하는 것이 좋습니다.
# $(dirname "$DESIGN_FILE")을 사용하여 디자인 파일이 있는 폴더를 include 경로로 잡습니다.
DESIGN_DIR=$(dirname "$DESIGN_FILE")

echo "[Step 1] Compiling..."
iverilog -I "$DESIGN_DIR" -o $OUTPUT_BIN "$DESIGN_FILE" "$TB_FILE" 2> compile_error.log

if [ $? -ne 0 ]; then
    echo "[Result] ❌ Compilation FAILED."
    cat compile_error.log
    # Log cleanup is optional; keeping it helps debug
    exit 1
fi

echo "[Result] ✅ Compilation SUCCESS."

# 2. Simulate
echo "[Step 2] Running Simulation..."
vvp $OUTPUT_BIN > $LOG_FILE

# 3. Judge
if grep -q "TEST PASSED" $LOG_FILE; then
    echo "[Result] 🎉 Verification PASSED!"
    echo "========================================="
    # Clean up executable to save space, keep logs
    rm -f $OUTPUT_BIN
    exit 0
else
    echo "[Result] ❌ Verification FAILED."
    echo "--- Head of Log ---"
    head -n 10 $LOG_FILE
    echo "..."
    echo "--- Tail of Log ---"
    tail -n 10 $LOG_FILE
    echo "-------------------"
    exit 2
fi
