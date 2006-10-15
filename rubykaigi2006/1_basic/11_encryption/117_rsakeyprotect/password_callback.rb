PasswordCallback = lambda { |for_encryption|
  print "Enter password: "
  pass = $stdin.gets.chop!
  if pass.length < 4
    $stderr.puts "password must be longer than 4 bytes"
    raise
  end
  if for_encryption
    print "Verify password: "
    pass2 = $stdin.gets.chop!
    if pass != pass2
      $stderr.puts "password does not match"
      raise
    end
  end
  pass
}
