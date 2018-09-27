node default {
    case $::operatingsystem {
        'Debian', 'Ubuntu' : { include jenkins }
        default  : { notify {"$::operatingsystem is not supported yet":} }
    }
}
