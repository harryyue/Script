day=`date +%Y-%m-%d`
echo $day

echo "clean coho start..."
rm -rf ./out/target/product/coho/*.img
rm -rf ./out/target/product/coho/kernel 
rm -rf ./out/target/product/coho/root/ 
rm -rf ./out/target/product/coho/obj/kernel/ 
rm -rf ./out/target/product/coho/system/ 
echo "clean coho end"


echo "source envsetup.sh satrt..."
source build/envsetup.sh
echo "source envsetup.sh end"

echo "lunch coho-eng start..."
lunch coho-eng
echo "finish lunch coho-eng"

echo "build image start..."
make bootimage -j8 2>&1 | tee bootimage$day.log
make kernel -j8 2>&1 | tee kernel$day.log
make systemimage -j4 2>&1 | tee flashfiles$day.log
echo "build image end"

