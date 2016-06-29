# myautossh

Auto Login SSH Server (expect-based)

##本项目思路以及部分源码取自
> https://github.com/wufeifei/autossh.git


# Install

```
$ git clone https://github.com/ooppwwqq0/myautossh.git
$ sudo cp myautossh/myautossh /usr/local/bin/a
```

# Config

```
$ cat ~/.ssh/autosshrc
server name|192.168.1.110|root|password|port|autosudo
wufeifei|192.168.1.1|root|password|22|1
```

# Usage

```
$ a
############################################################
#                     [AUTO SSH]                           #
#                                                          #
#                                                          #
# [1] 192.168.1.110:feei                                   #
# [2] 10.11.2.103:root                                     #
# [3] 103.21.140.84:root                                   #
#                                                          #
#                                                          #
############################################################
Server Number:(Input Server Num)
```

OR

```
$ a 1
```

OR Auto Sudo

```
$ a 3 sudo
```

OR Bastion Host

```
$ a 1 10.12.0.123
```

OR Auto Sudo With Bastion

```
$ a 1 10.11.0.123 sudo
```
