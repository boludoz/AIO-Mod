#RequireAdmin
$message = "AAAAAAAAAAAAAAAAAAAA"
Sleep(1000)
For $i = 1 To StringLen($message)
ClipPut(StringMid($message, $i, 1))
Send("^v")
Next
