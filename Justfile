

run:
    odin run .

test:
    { \
        find . -name '*_test.odin' -not -path './.git/*' -exec dirname {} \; ; \
        rg -l '@\(test\)' --glob '*.odin' | xargs -r -n1 dirname ; \
    } \
    | sort -u \
    | xargs -P 0 -I{} odin test {}
