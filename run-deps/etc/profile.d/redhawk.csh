if (! $?OSSIEHOME) then
    setenv OSSIEHOME /opt/redhawk/core

    if ($?PATH) then
        setenv PATH /opt/redhawk/core/bin:${PATH}
    else
        setenv PATH /opt/redhawk/core/bin
    endif

    if ($?LD_LIBRARY_PATH) then
        setenv LD_LIBRARY_PATH /opt/redhawk/core/lib64:${LD_LIBRARY_PATH}
    else
        setenv LD_LIBRARY_PATH /opt/redhawk/core/lib64
    endif

    if ($?PYTHONPATH) then
        setenv PYTHONPATH $OSSIEHOME/lib64/python:$OSSIEHOME/lib/python:${PYTHONPATH}
    else
        setenv PYTHONPATH $OSSIEHOME/lib64/python:$OSSIEHOME/lib/python
    endif
endif
if (! $?LD_LIBRARY_PATH) then
    setenv LD_LIBRARY_PATH /opt/redhawk/core/lib64
endif

