echo "*** Started Execution *****"

echo "bank-marketing-data-loading.py"
spark-submit  "/home/subrat/bank-marketing-data-loading.py"

if [ $? -eq 0 ]
then
    echo "executing bank-marketing-validation.py"
    spark-submit "/home/subrat/bank-marketing-data-validation.py"

    if [ $? -eq 0 ]
    then
        echo "executing bank-marketing-tranformation.py"
        spark-submit  --packages org.apache.spark:spark-avro_2.12:3.3.2 "/home/subrat/bank-marketing-data-transformation.py"

        if [ $? -eq 0 ]
        then
            echo "executing bank-marketing-export.py"
            spark-submit --jars "/home/subrat/mysql-connector-j-8.0.32/mysql-connector-j-8.0.32.jar"  --packages org.apache.spark:spark-avro_2.12:3.3.2 "/home/subrat/bank-marketing-data-export.py"

            if [ $? -eq 0 ]
            then
                echo  "All Jobs done"
            else
                echo "============== ERROR in bank_export.py  ==================="
            fi
        else
            echo "============== ERROR in bank_transformation.py  ==================="
        fi
    else
        echo "================ ERROR in bank_cleaning.py  ===================="
    fi
else
    echo "================ ERROR in FILE bank_load.py =================="
fi
echo "Good Work :)"
