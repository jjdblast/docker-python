FROM jiandong/anaconda3:latest

# Use a fixed apt-get repo to stop intermittent failures due to flaky httpredir connections,
# as described by Lionel Chan at http://stackoverflow.com/a/37426929/5881346
RUN apt-get update && apt-get install -y build-essential && \
    apt-get install -y autotools-dev automake && \
    cd /usr/local/src && \
    pip install tensorflow && \
    # Vowpal Rabbit : Get libboost program-optiVons and zlib:
    apt-get install -y libboost-program-options-dev zlib1g-dev libboost-python-dev && \
    git clone git://github.com/JohnLangford/vowpal_wabbit.git && \
    cd vowpal_wabbit && ./autogen.sh && make && make install && \
    cd ../ && rm -rf vowpal_wabbit && \
    # python wrapper
    pip install vowpalwabbit && \
    pip install seaborn python-dateutil dask pytagcloud pyyaml ggplot joblib husl geopy ml_metrics mne pyshp gensim && \
    conda install -y -c conda-forge spacy && python -m spacy download en && \
    # configure the dbus for imagemagick
    mkdir /opt/conda/var/lib/ && mkdir /opt/conda/var/lib/dbus && touch /opt/conda/var/lib/dbus/machine-id && \
    dbus-uuidgen > /opt/conda/var/lib/dbus/machine-id && \
    # install imagemagick
    apt-get -y install imagemagick && \
    # For opencv
    apt-get -y install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get -y install libtbb2 libtbb-dev libjpeg-dev libtiff-dev libjasper-dev && \
    apt-get -y install cmake && \
    cd /usr/local/src && git clone --depth 1 https://github.com/Itseez/opencv.git && \
    cd opencv && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D WITH_FFMPEG=OFF -D WITH_V4L=ON -D WITH_QT=OFF -D WITH_OPENGL=ON -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.6m.so -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.6m/ -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.so -D PYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m/ -D BUILD_PNG=TRUE .. && \
    make -j $(nproc) && make install && \
    echo "/usr/local/lib/python3.6/site-packages" > /etc/ld.so.conf.d/opencv.conf && ldconfig && \
    cp /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so /opt/conda/lib/python3.6/site-packages/ && \
    # Clean up install cruft
    rm -rf /usr/local/src/opencv && \
    rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && apt-get clean

