FROM ctalapp/ctapipe:latest
MAINTAINER CTA LAPP <cta-pipeline-lapp@in2p3.fr>

ARG CTA_ANALYSIS_CLONE_URL=https://gitlab.in2p3.fr/CTA-LAPP/CTA_Analysis.git
ARG CTA_ANALYSIS_VERSION=master
ARG SWIG_VERSION=3.0.12

ADD eigen3.werror.diff /tmp/

# Install CTA_Analysis dependencies
RUN source activate ${CONDA_ENV} \
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
 && rm -rf /tmp swig-${SWIG_VERSION}.tar.gz swig-${SWIG_VERSION}

# Clone CTA_Analysis GIT repository
RUN source activate ${CONDA_ENV} \
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
