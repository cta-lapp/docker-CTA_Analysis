FROM ctalapp/ctapipe:latest
MAINTAINER CTA LAPP <cta-pipeline-lapp@in2p3.fr>

ARG CTA_ANALYSIS_CLONE_URL=https://gitlab.in2p3.fr/CTA-LAPP/CTA_Analysis.git
ARG CTA_ANALYSIS_VERSION=master
ARG SWIG_VERSION=3.0.12
ARG GOOGLE_BENCHMARK_VERSION=v1.1.0

ADD eigen3.werror.diff /tmp/

# Install CTA_Analysis dependencies
RUN source activate ${CONDA_ENV} \
 && mkdir -p /root/.config/matplotlib \
 && echo "backend : Agg" > /root/.config/matplotlib/matplotlibrc \
 && conda install -n ${CONDA_ENV} -c menpo eigen \
 && cd /opt/conda/envs/${CONDA_ENV}/include && patch -p0 </tmp/eigen3.werror.diff \
 && cd /tmp \
 && curl -O -J -L https://downloads.sourceforge.net/project/swig/swig/swig-${SWIG_VERSION}/swig-${SWIG_VERSION}.tar.gz \
 && tar zxf swig-${SWIG_VERSION}.tar.gz \
 && cd swig-${SWIG_VERSION} \
 && source activate ${CONDA_ENV} \
 && ./configure \
 && make -j`grep -c '^processor' /proc/cpuinfo` \
 && make install \
 && rm -rf /tmp swig-${SWIG_VERSION}.tar.gz swig-${SWIG_VERSION} \
 && cd /opt \
 && git clone https://github.com/google/benchmark.git /opt/benchmark \
 && cd /opt/benchmark \
 && git checkout ${GOOGLE_BENCHMARK_VERSION} \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
 && make all install \
 && rm -rf /opt/benchmark \
 && cd /opt \
 && pip install cython matplotlib==1.5.2

# Clone CTA_Analysis GIT repository
RUN source activate ${CONDA_ENV} \
 && conda install pytest \
 && git clone $CTA_ANALYSIS_CLONE_URL /opt/CTA_Analysis \
 && cd /opt/CTA_Analysis \
 && git checkout $CTA_ANALYSIS_VERSION

# Build and install CTA_Analysis
RUN source activate ${CONDA_ENV} \
 && cd /opt/CTA_Analysis \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DRELEASE_MODE=no -DUSE_PYTHON=yes -DEIGEN_INCLUDE_DIR=/opt/conda/envs/${CONDA_ENV}/include -DPYTHON_INCLUDE_DIR=/opt/conda/envs/${CONDA_ENV}/include/python3.5m -DPYTHON_LIBRARY=/opt/conda/envs/${CONDA_ENV}/lib/libpython3.5m.so \
 && make -j`grep -c '^processor' /proc/cpuinfo` all install \
 && ldconfig

RUN mkdir /tmp ; chmod 777 /tmp ; chmod +t /tmp
ENV PYTHON_EGG_CACHE=/tmp/.cache
