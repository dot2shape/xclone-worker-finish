# x-clone 마감 모델 실험 워커 — ComfyUI 서버리스 베이스 + IP-Adapter(FaceID) 커스텀 노드
# 모델은 Runpod 네트워크 볼륨(/runpod-volume/models/...)에 둔다. 이미지에는 노드·의존성만.
FROM runpod/worker-comfyui:5.10.0-base

# IP-Adapter plus (FaceID 포함). FaceID 는 insightface + onnxruntime 필요
RUN comfy-node-install comfyui_ipadapter_plus

RUN (apt-get update && apt-get install -y --no-install-recommends build-essential cmake && rm -rf /var/lib/apt/lists/*) || true \
 && pip install --no-cache-dir "insightface==0.7.3" onnxruntime-gpu onnxruntime opencv-python-headless

# 볼륨 모델 경로 확장(style_models·ipadapter·insightface) — 기본 yaml 덮어쓰기
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
