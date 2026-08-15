

run:
  odin run .


test:
  find . -type d | grep -v .git | xargs -n 1 odin test
