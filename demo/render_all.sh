#!/bin/bash
# Render all demos to specified format
# Usage: ./render_all.sh [svg|png|pdf]

FORMAT=${1:-svg}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT_DIR="$SCRIPT_DIR/inputs"
OUTPUT_DIR="$SCRIPT_DIR/outputs"
EXE="$SCRIPT_DIR/../bin/simple_graphviz.exe"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Rendering all demos to $FORMAT format..."
echo "========================================="

# Demo files with their recommended engines
declare -A ENGINES=(
    ["01_simple_inheritance"]="dot"
    ["02_eiffel_class_hierarchy"]="dot"
    ["03_microservices_architecture"]="dot"
    ["04_database_schema"]="dot"
    ["05_traffic_light_fsm"]="dot"
    ["06_order_processing_fsm"]="dot"
    ["07_login_flowchart"]="dot"
    ["08_cicd_pipeline"]="dot"
    ["09_network_topology"]="neato"
    ["10_library_dependencies"]="dot"
    ["11_org_chart"]="dot"
    ["12_decision_tree"]="dot"
    ["13_git_branching"]="dot"
    ["14_api_sequence"]="dot"
    ["15_data_pipeline"]="dot"
    ["16_sorting_algorithm"]="dot"
    ["17_regex_automaton"]="dot"
    ["18_mind_map"]="twopi"
    ["19_component_diagram"]="dot"
    ["20_bon_eiffel_design"]="dot"
)

PASS=0
FAIL=0

for NAME in "${!ENGINES[@]}"; do
    ENGINE="${ENGINES[$NAME]}"
    INPUT="$INPUT_DIR/${NAME}.dot"
    OUTPUT="$OUTPUT_DIR/${NAME}.${FORMAT}"

    if [ -f "$INPUT" ]; then
        echo -n "  $NAME ($ENGINE) -> $FORMAT ... "
        "$EXE" render "$INPUT" -o "$OUTPUT" -f "$FORMAT" -e "$ENGINE" > /dev/null 2>&1
        if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
            echo "[PASS]"
            ((PASS++))
        else
            echo "[FAIL]"
            ((FAIL++))
        fi
    else
        echo "  $NAME ... [SKIP - input not found]"
    fi
done

echo "========================================="
echo "Passed: $PASS, Failed: $FAIL"
echo "Outputs: $OUTPUT_DIR"
