from flask import Flask, request, jsonify
from models import db, Score
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get("DB_URL")
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)


@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok"}), 200


@app.route('/submit', methods=['POST'])
def submit_score():
    data = request.get_json()
    name = data.get('name')
    score = data.get('score')

    if not name or not isinstance(score, int):
        return jsonify({"error": "Invalid input"}), 400

    new_score = Score(name=name, score=score)
    db.session.add(new_score)
    db.session.commit()

    return jsonify({"message": "Score submitted", "id": new_score.id}), 201


@app.route("/results", methods=["GET"])
def get_results():
    results = Score.query.order_by(Score.timestamp.desc()).all()
    data = []
    for r in results:
        data.append({
            "id": r.id,
            "name": r.name,
            "score": r.score,
            "timestamp": r.timestamp.isoformat()
        })
    return jsonify(data)


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=os.getenv("FLASK_APP_PORT"))
