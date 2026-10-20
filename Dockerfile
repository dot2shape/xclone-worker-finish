# x-clone 마감 모델 실험 워커 — ComfyUI 서버리스 베이스 + IP-Adapter(FaceID) 커스텀 노드
# 모델은 Runpod 네트워크 볼륨(/runpod-volume/models/...)에 둔다. 이미지에는 노드·의존성만.
FROM runpod/worker-comfyui:5.10.0-base

# IP-Adapter plus (FaceID 포함)
RUN comfy-node-install comfyui_ipadapter_plus

# FaceID 의존성: insightface 는 소스 빌드라 Cython·numpy 가 먼저 필요하고 빌드 격리를 끈다
RUN (apt-get update && apt-get install -y --no-install-recommends build-essential cmake && rm -rf /var/lib/apt/lists/*) || true \
 && pip install --no-cache-dir "cython<3.1" numpy setuptools wheel \
 && pip install --no-cache-dir --no-build-isolation "insightface==0.7.3" \
 && pip install --no-cache-dir onnxruntime-gpu onnxruntime opencv-python-headless \
 && python -c "import insightface, onnxruntime; print('insightface', insightface.__version__, 'ort', onnxruntime.__version__)"

# 볼륨 모델 경로 확장(style_models·ipadapter·insightface) — 기본 yaml 덮어쓰기
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
