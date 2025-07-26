from flask import Flask, request, jsonify
import subprocess
import tempfile
import sys

app = Flask(__name__)

@app.route("/bestmove", methods=["POST"])
def bestmove():
    print("Flask app received request.", file=sys.stderr)
    fen = request.json.get("fen")
    if not fen:
        print("Error: FEN missing in request.", file=sys.stderr)
        return jsonify({"error": "FEN missing"}), 400

    print(f"Received FEN: {fen}", file=sys.stderr)

    with tempfile.NamedTemporaryFile("w+", delete=False) as f:
        f.write(f"position fen {fen}\ngo\n")
        f.flush()
        temp_file_name = f.name

    print(f"Created temporary Lc0 input file: {temp_file_name}", file=sys.stderr)

    try:
        # Execute lc0, capturing both stdout and stderr
        process = subprocess.run(
            ["./lc0", "--weights=weights.pb.gz"],
            stdin=open(temp_file_name, "r"),
            capture_output=True, # Capture both stdout and stderr
            text=True, # Decode stdout/stderr as text
            timeout=30 # Increased timeout for lc0 execution
        )
        
        print(f"Lc0 stdout: {process.stdout}", file=sys.stderr)
        print(f"Lc0 stderr: {process.stderr}", file=sys.stderr)

        if process.returncode != 0:
            print(f"Lc0 exited with non-zero code: {process.returncode}", file=sys.stderr)
            return jsonify({"error": f"Lc0 exited with error: {process.stderr}"}), 500

        for line in process.stdout.splitlines():
            if line.startswith("bestmove"):
                move = line.strip().split(" ")[1]
                print(f"Found bestmove: {move}", file=sys.stderr)
                return jsonify({"bestmove": move})

        print("Error: No bestmove found in Lc0 output.", file=sys.stderr)
        return jsonify({"error": "No move found"}), 500

    except subprocess.TimeoutExpired as e:
        print(f"Error: Lc0 timed out. Stdout: {e.stdout}, Stderr: {e.stderr}", file=sys.stderr)
        return jsonify({"error": "Lc0 timed out"}), 500
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500
    finally:
        # Clean up the temporary file
        import os
        os.remove(temp_file_name)
        print(f"Cleaned up temporary file: {temp_file_name}", file=sys.stderr)

if __name__ == "__main__":
    print("Flask app starting...", file=sys.stderr)
    app.run(host="0.0.0.0", port=5000)
