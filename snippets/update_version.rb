MYVERSION = '1.001'
## Call script to do updateVersion from .git/hooks/pre-commit
def updateVersion
  # We add 1 because the next commit is probably one more - though this is a race
  commits = %x[git log #{$0} | grep '^commit ' | wc -l].to_i + 1
  vers = "1.%0.3d" % commits

  t = File.read($0)
  t.gsub!(/^MYVERSION = '(.*)'$/, "MYVERSION = '#{vers}'")
  bak = $0+'.bak'
  File.open(bak,'w') { |f| f.puts t }
  perm = File.stat($0).mode & 0xfff
  File.rename(bak,$0)
  File.chmod(perm,$0)
  exit
end

updateVersion
