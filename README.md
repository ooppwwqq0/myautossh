# myautossh

Auto Login SSH Server (expect-based)

##本项目思路以及部分源码取自
> https://github.com/wufeifei/autossh.git


# Install

```
$ git clone https://github.com/ooppwwqq0/myautossh.git
$ sudo cp myautossh/myautossh /usr/local/bin/a
$ sudo chmod +x /usr/local/bin/a
```

# Config

```
$ cat ~/.ssh/autosshrc
server name|ip|user name|password|port|enable autosudo
my server|192.168.1.1|wangping|password|22|1
```

# Usage

```
$ a
############################################################
#                     [AUTO SSH]                           #
#                                                          #
#                                                          #
# [1] 192.168.1.1:wang                                   #
# [2] 10.0.0.1:root                                     #
# [3] 172.18.1.1:root                                   #
#                                                          #
#                                                          #
############################################################
Server Number:(Input Server Num)
```

OR

```
$ a 1
```

OR Last Login

```
a !
```

OR Auto Sudo

```
$ a 3 sudo
```

OR Bastion Host And Auto Add Recode

```
$ a x 192.168.1.1
```

OR Del Recode

```
a d 192.168.1.1
```

