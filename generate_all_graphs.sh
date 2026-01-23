#!/bin/bash
# Generate documentation graphs for all simple_* libraries
# Part of the Simple Eiffel ecosystem
#
# Each library gets its graphs in its own folder:
#   /d/prod/simple_json/graphs/
#   /d/prod/simple_xml/graphs/
#   etc.

set -e

EXE="/d/prod/simple_graphviz/bin/eiffel_graph_gen.exe"

# Check if executable exists
if [ ! -f "$EXE" ]; then
    echo "Error: Executable not found at $EXE"
    echo "Please compile first:"
    echo "  cd /d/prod/simple_graphviz"
    echo "  /d/prod/ec.sh -batch -config simple_graphviz.ecf -target eiffel_graph_gen -finalize -c_compile"
    exit 1
fi

echo "=========================================="
echo "Eiffel Graph Generator - Batch Processing"
echo "=========================================="
echo "Graphs will be placed in each library's own folder"
echo ""

# Counter for statistics
total=0
success=0
failed=0
failed_libs=""

# Process each simple_* library
for lib in /d/prod/simple_*; do
    if [ -d "$lib" ]; then
        # Find main ECF file (not test ECF)
        ECF=$(find "$lib" -maxdepth 1 -name "*.ecf" ! -name "*test*" 2>/dev/null | head -1)

        if [ -n "$ECF" ]; then
            lib_name=$(basename "$lib")
            total=$((total + 1))

            echo -n "[$total] $lib_name ... "

            # Use "." as output dir - generator will use ECF's parent directory
            if "$EXE" "$ECF" -o "." 2>/dev/null; then
                echo "OK -> $lib/graphs/"
                success=$((success + 1))
            else
                echo "FAILED"
                failed=$((failed + 1))
                failed_libs="$failed_libs $lib_name"
            fi
        fi
    fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total libraries: $total"
echo "Successful:      $success"
echo "Failed:          $failed"

if [ -n "$failed_libs" ]; then
    echo ""
    echo "Failed libraries:$failed_libs"
fi

echo ""
echo "Graphs are in each library's /graphs/ folder"
echo ""

# Show sample of generated graph directories
echo "Sample generated graph locations:"
count=0
for lib in /d/prod/simple_*; do
    if [ -d "$lib/graphs" ]; then
        count=$((count + 1))
        if [ $count -le 10 ]; then
            echo "  $lib/graphs/"
        fi
    fi
done
if [ $count -gt 10 ]; then
    echo "  ... and $((count - 10)) more"
fi
