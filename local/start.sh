lsnrctl start && sqlplus / as sysdba << EOF
    startup;
    exit;
EOF

tail -f $ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace/alert_$ORACLE_SID.log
