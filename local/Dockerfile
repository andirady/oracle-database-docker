FROM oracledist:12.2.0.1

COPY packages.txt /tmp
RUN dnf install -y $(cat /tmp/packages.txt) && \
    dnf clean all && \
    rm /tmp/packages.txt && \
    ln -s /usr/lib64/libnsl.so.2.0.0 /usr/lib64/libnsl.so.1 && \
    ln -s /usr/lib/libnsl.so.2.0.0 /usr/lib/libnsl.so.1

RUN groupadd oinstall && \
    groupadd dba && \
    useradd -g oinstall -G dba oracle && \
    mkdir -p /u01/app/oracle/product/12.2.0.1/db_1 && \
    chown -R oracle:oinstall /u01 && \
    chmod -R 775 /u01

ENV ORACLE_BASE=/u01/app/oracle \
    ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/db_1 \
    LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib \
    CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib \
    PATH=${ORACLE_HOME}/bin:$PATH

USER oracle
COPY dbca.rsp netca.rsp /home/oracle/
WORKDIR /tmp/oracle_inst/database
RUN ./runInstaller -ignoreSysPrereqs \
                   -waitforcompletion \
                   -showProgress \
                   -silent \
                   -responseFile /tmp/oracle_inst/database/response/db_install.rsp \
                   oracle.install.option=INSTALL_DB_SWONLY \
                   UNIX_GROUP_NAME=dba \
                   INVENTORY_LOCATION=/u01/app/oraInventory \
                   ORACLE_HOME=${ORACLE_HOME} \
                   ORACLE_BASE=${ORACLE_BASE} \
                   oracle.install.db.InstallEdition=SE2 \
                   oracle.install.db.OSDBA_GROUP=dba \
                   oracle.install.db.OSOPER_GROUP=dba \
                   oracle.install.db.OSBACKUPDBA_GROUP=dba \
                   oracle.install.db.OSDGDBA_GROUP=dba \
                   oracle.install.db.OSKMDBA_GROUP=dba \
                   oracle.install.db.OSRACDBA_GROUP=dba


USER root
RUN /u01/app/oraInventory/orainstRoot.sh && \
    /u01/app/oracle/product/12.2.0.1/db_1/root.sh
RUN rm -r /tmp/oracle_inst

USER oracle
WORKDIR ${ORACLE_HOME}
ENV ORACLE_BASE=/u01/app/oracle \
    ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/db_1 \
    LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib \
    CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib \
    PATH=${ORACLE_HOME}/bin:$PATH
RUN rm -v ${ORACLE_HOME}/lib/stubs/libc* && \
    relink all
ENV LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib \
    CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib \
    PATH=${ORACLE_HOME}/bin:$PATH
RUN dbca -silent -createDatabase -ignorePreReqs -responseFile /home/oracle/dbca.rsp || \
    cat ${ORACLE_BASE}/cfgtoollogs/dbca/orcl/orcl.log

WORKDIR /home/oracle
ENV ORACLE_SID=orcl
COPY listener.ora tnsnames.ora ${ORACLE_HOME}/network/admin/
COPY start.sh /home/oracle/
EXPOSE 1521 5500

CMD /home/oracle/start.sh
