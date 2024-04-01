# Network Size N
for i in 50; do
    N=`bc -l <<<"scale=0;$i"`
# HIV Prevalence
    for j in 0.1; do
        phiv=`bc -l  <<< "scale=1; $j"`
# Initial PrEP Coverage strategy   
        for k in 0.2; do
            PrEP1=`bc -l  <<< "scale=1; $k"`
# Counterfactual PrEP coverage strategy
            for l in 0.4; do
                PrEP2=`bc -l  <<< "scale=1; $l"`
# P(HIV | Contact and No PrEP)
                for m in `seq 0.1 0.1 1`; do
                    p1=`bc -l  <<< "scale=1; $m"`
# P(HIV | Contact and PrEP)        
                    for n in `seq 0.1 0.1  1`; do
                        p2=`bc -l  <<< "scale=1; $n"`
# Network Generative Model 
                        for o in "ER"; do
                            model="$o"
# Number of realizations
                           for nsim in 200; do
#                             for p in "{nsims[@]}"; do
#                                 nsim=`bc -l <<< "scale=0;$p"`
#                                for p in `seq 1 1 3`; do
#                                nsim= =$(echo (10**p) | bc)
                                echo "N=$N phiv=$phiv PrEP1=$PrEP1 PrEP2=$PrEP2 p1=$p1 p2=$p2 model=$model nsim=$nsim"
                                qsub simnets.qsub $N $phiv $PrEP1 $PrEP2 $p1 $p2 $model $nsim
                            done
                        done
                    done
                done
            done
        done
    done
done
