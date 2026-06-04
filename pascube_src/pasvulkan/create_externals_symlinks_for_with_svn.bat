@echo off
if not exist externals mkdir externals 2>nul
if not exist externals\pasmp mklink /J externals\pasmp ..\..\PASMP.github\trunk
if not exist externals\pucu mklink /J externals\pucu ..\..\PUCU.github\trunk
if not exist externals\pasdblstrutils mklink /J externals\pasdblstrutils ..\..\PASDBLSTRUTILS.github\trunk
if not exist externals\kraft mklink /J externals\kraft ..\..\KRAFT.github\trunk
if not exist externals\pasjson mklink /J externals\pasjson ..\..\PASJSON.github\trunk
if not exist externals\pasgltf mklink /J externals\pasgltf ..\..\PASGLTF.github\trunk
if not exist externals\rnl mklink /J externals\rnl ..\..\RNL.github\trunk
if not exist externals\flre mklink /J externals\flre ..\..\FLRE.github\trunk
if not exist externals\poca mklink /J externals\poca ..\..\POCA.github\trunk

