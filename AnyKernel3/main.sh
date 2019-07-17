chmod -R 0755 $TMPDIR/addon/AnyKernel3
cp -R $TMPDIR/addon/AnyKernel3/tools $UF 2>/dev/null

ui_print " " "AnyKernel3 by osm0sis @ xda-developers" " " " ";

if [ ! "$(getprop 2>/dev/null)" ]; then
  getprop() {
    local propval="$(grep_prop $1 /default.prop 2>/dev/null)";
    test "$propval" || local propval="$(grep_prop $1 2>/dev/null)";
    test "$propval" && echo "$propval" || echo "";
  }
elif [ ! "$(getprop ro.product.device 2>/dev/null)" -a ! "$(getprop ro.build.product 2>/dev/null)" ]; then
  getprop() {
    ($(which getprop) | grep "$1" | cut -d[ -f3 | cut -d] -f1) 2>/dev/null;
  }
fi;

if [ "$(grep_prop do.devicecheck anykernel.sh)" == 1 ]; then
  ui_print "Checking device...";
  device="$(getprop ro.product.device)";
  product="$(getprop ro.build.product)";
  for testname in $(grep_prop 'device.name.*' anykernel.sh); do
    if [ "$device" == "$testname" -o "$product" == "$testname" ]; then
      ui_print "$testname";
      match=1;
      break;
    fi;
  done;
  ui_print " ";
  if [ ! "$match" ]; then
    abort "Unsupported device. Aborting...";
  fi;
fi;

sed -i "s|^. ak3.*core.sh|. ak3-core.sh|" $TMPDIR/addon/AnyKernel3/anykernel.sh
for i in $(sed -n '/^# shell variables/,/^$/p' $TMPDIR/addon/AnyKernel3/anykernel.sh | sed '1d;$d'); do
  eval $i
  sed -i "s|$i|#$i|" $TMPDIR/addon/AnyKernel3/anykernel.sh
done
[ -z $OG_AK ] && OG_AK=false
. $TMPDIR/addon/AnyKernel3/ak3-core.sh
$OG_AK && split_boot || dump_boot
