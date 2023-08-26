FROM nvcr.io/nvidia/pytorch:23.07-py3 as build
RUN set -xe \
    && apt-get update \
    && apt-get install python3-pip python-dev-is-python3 -y
# RUN pip install --no-cache-dir --upgrade pip
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel
COPY ./requirements.txt /requirements.txt
# RUN pip install torch torchvision torchaudio torch-tensorrt torchtext --extra-index-url https://download.pytorch.org/whl/cu118 xformers
# RUN pip install llvmlite cython numba
RUN pip install opencv-contrib-python
RUN pip install --no-cache-dir -r /requirements.txt
WORKDIR /usr/app
COPY ./web ./web
COPY ./comfy ./comfy
COPY ./comfy_extras ./comfy_extras
COPY ./custom_nodes ./custom_nodes
COPY ./notebooks ./notebooks
COPY ./script_examples ./script_examples
COPY ./input ./input
COPY ./output ./output
COPY ./models ./models
COPY *.py ./
# RUN find custom_nodes -type f -name "prestartup_script.py" -exec python {} \;
RUN python -c "import os, time; node_paths = [d[0] for d in os.walk('custom_nodes') if 'prestartup_script.py' in d[2]]; node_prestartup_times = []; [node_prestartup_times.append((time.time(), p)) for p in node_paths if os.system(f'python {os.path.join(p, \"prestartup_script.py\")}') == 0]; [print(f'{n[0]} seconds: {n[1]}') for n in node_prestartup_times]"
CMD ["python", "main.py", "--listen", "--enable-cors-header"]