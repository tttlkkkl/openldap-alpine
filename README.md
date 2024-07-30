## 关于

本项目结合[ldap-alpine](https://github.com/gitphill/ldap-alpine) 和 [openssl-alpine](https://github.com/gitphill/openssl-alpine) 建立。是一个比较完全的 LDAP 使用示例。

## 快速开始

- 克隆本项目到本地。
- 创建 docker 网络：

```bash
docker network create ops
```

- 启动 ldap 服务：

```bash
docker-compose -f docker-compose/docker-compose.yml up -d
```

- 导入预置用户：

```bash
# 进入 ldap 容器
docker exec -it ldap /bin/sh
# 导入用户和用户组
ldapadd -Z -D 'cn=root,dc=lihuaio,dc=com' -w 'admin' -f /example.ldif
# 检查 memberOf 是否有效
ldapsearch -x -LL  -D 'cn=root,dc=lihuaio,dc=com' -w "admin" -b ou=Users,dc=lihuaio,dc=com  memberOf
```

memberOf 有效时应该输出如下结果：

```bash
version: 1

dn: ou=Users,dc=lihuaio,dc=com

dn: uid=111,ou=Users,dc=lihuaio,dc=com
memberOf: cn=dev,ou=Groups,dc=lihuaio,dc=com

dn: uid=api,ou=Users,dc=lihuaio,dc=com

dn: uid=read,ou=Users,dc=lihuaio,dc=com

dn: uid=super,ou=Users,dc=lihuaio,dc=com
memberOf: cn=super,cn=grafana,ou=Groups,dc=lihuaio,dc=com

dn: uid=editor,ou=Users,dc=lihuaio,dc=com
memberOf: cn=editor,cn=grafana,ou=Groups,dc=lihuaio,dc=com

dn: uid=viewer,ou=Users,dc=lihuaio,dc=com
memberOf: cn=viewer,cn=grafana,ou=Groups,dc=lihuaio,dc=com
```

- 启动 grafan

```bash
docker-compose -f grafana-compose.yml up
```

- 之后就可以使用 ldap 用户登录 grafana 了。浏览器打开`127.0.0.1:3000` 输入账号 `super` ，密码: `123` ，进行登录。

### 用户密码备注

- 示例所有预置用户密码都是 `123` 。
- 示例 ldap 超管账号为 `cn=root,dc=lihuaio,dc=com` 密码为：`admin`

### 项目效果

- ldap 预置用户和用户组
  ![ldap-admin](https://github.com/tttlkkkl/openldap-alpine/blob/master/images/ldap.png)
- grafana 接入效果
  ![grafana ldap](https://github.com/tttlkkkl/openldap-alpine/blob/master/images/grafana-ldap.png)
- super 用户登录 grafana
  ![grafana ldap login](https://github.com/tttlkkkl/openldap-alpine/blob/master/images/grafana-super.png)

### 图形化管理工具推荐

- windows：`Ldap Admin`
- macos：`Ldap Admin Toll` ,这是一个付费工具。

## ssl 证书签发

此选项不是必须，如果不设置 `CA_FILE`、`KEY_FILE`、`CERT_FILE` 环境变量的话将使用`ldap:///`启动服务。

- 要部署到自己的服务器环境中需要正确的设置证书的 `CN` 字段。把 ldap 连接服务器需要的的域名、ip 填到`public.ext` 文件的 `alt_names` 配置项下面，如下：

```bash
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
IP.1=127.0.0.1
DNS.2 = ldap
DNS.3 = ldap.lihuaio.com
```

`注意：自定义内容请从 DNS.2 开始，DNS.1 预留。`

- 更改 `openssl-compose.yml` 文件中的环境变量：

| 环境变量         | 范例               | 说明                                                                                     |
| ---------------- | ------------------ | ---------------------------------------------------------------------------------------- |
| COUNTY:          | "CN"               | 国家                                                                                     |
| STATE:           | "GD"               | 州、省份                                                                                 |
| LOCATION:        | "shenzhen"         | 城市                                                                                     |
| ORGANISATION:    | "lihuaio"          | 组织名字                                                                                 |
| ROOT_CN:         | "lihuaio"          | 根证书组织名字                                                                           |
| ISSUER_CN:       | "lihuaio"          | CA 签发机构名称                                                                          |
| ROOT_NAME:       | "root"             | 根证书名称                                                                               |
| ISSUER_NAME:     | "lihuaio"          | 证书签发机构名称                                                                         |
| PUBLIC_NAME:     | "ldap"             | 当前签发的证书的名称，如果要签发新的证书则设定这个值，新证书文件名以及组织都使用这个值。 |
| PUBLIC_CN:       | "ldap.lihuaio.com" | 证书 `CN` ，这个值最终会被写入到 `public.ext` 文件中                                     |
| RSA_KEY_NUMBITS: | "2048"             | 签名算法                                                                                 |
| DAYS:            | "3650"             | 证书有效天数                                                                             |
| KEYSTORE_NAME:   | "keystore"         | keystore 名称                                                                            |
| KEYSTORE_PASS:   | "dn@2019.06.12#ad" | keystore 密码                                                                            |
| CERT_DIR:        | "/etc/ssl/certs"   | 证书生成路径，将此目录挂载到本地路径中以便使用生成的证书                                 |

- 执行签发命令

```bash
docker-compose -f docker-compose/openssl-compose.yml up
```

此命令将会生成根证书、证书签发机构证书、根 CA、以及目标证书也即本项目使用的 ldap 服务的证书。

## LDAP 服务说明

- 本项目的 `LDAP` 基于 `Alpine` 构建的 `Openldap` 服务，使用 `mdb` 作为数据库。
- 除去`docker-compose/ldif/default.ldif`中的示例内容，默认的会生成一个组织和一个用户组，内容取决于服务配置：

```ldif
dn: dc=lihuaio,dc=com
objectClass: dcObject
objectClass: organization
o: lihuaio
dc: lihuaio

dn: ou=Users,dc=lihuaio,dc=com
ou: Users
objectClass: organizationalUnit
```

### LDAP 服务配置项

| 配置项            | 范例                    | 说明                                                                                                                                                             |
| ----------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ORGANISATION_NAME | lihuaio                 | 初始组织名称                                                                                                                                                     |
| SUFFIX            | dc=lihuaio,dc=com       | base DN                                                                                                                                                          |
| ROOT_USER         | root                    | 超级管理账号名称                                                                                                                                                 |
| ROOT_PW           | 'admin'                 | 超级管理账号密码，将自动调用 `slappasswd` 指令处理                                                                                                               |
| CA_FILE           | /etc/ssl/certs/ca.pem   | 根 CA 证书路径                                                                                                                                                   |
| KEY_FILE          | /etc/ssl/certs/ldap.key | 密钥路径                                                                                                                                                         |
| CERT_FILE         | /etc/ssl/certs/ldap.crt | 证书路径                                                                                                                                                         |
| TLS_VERIFY_CLIENT | never                   | TLS 验证级别，可选值：try, never, demand,allow。这里如果配置为 demand 将导致 `ldap admin` 等其他接入系统无法使用，因为这意味着开启双向验证。客户端也要提供证书。 |
| LOG_LEVEL         | stats                   | 日志级别，详细见：[ldap log](https://www.openldap.org/doc/admin25/monitoringslapd.html#Log)                                                                      |

- 设置证书路径后你需要提供正确的证书，此时 ldap 服务将以 `ldaps:///` 启动。

### LDAP 挂载目录说明

- `/etc/ssl/certs` : 证书路径，取决于证书环境变量的设置。
- `/var/lib/openldap/openldap-data/`: ldap 服务数据存储路径，正式使用时需要将此目录挂载到安全的存储位置。
- `/etc/openldap/access.conf`: ldap ACL 配置。
- `/ldif`: 备份还原路径，ldap 服务启动时将会自动导入此目录下的所有 `ldif` 文件。注意，当遇到任何错误时终止导入。通过该目录导入数据不会生成 `memberOf` 等行为属性。
- `/root/.ldaprc` ldap 命令行客户端连接配置，如果你不希望在 docker 容器中轻易连接客户端，请删除此文件的挂载。

### LDAP ACL 示例说明

- 详细内容见 `docker-compose/access.conf` 文件。
- `uid=api,ou=Users,dc=lihuaio,dc=com` 账号用于内部系统员工自助修改密码，只有用户的读取权限但是单独可以修改密码，可以用于员工编写员工密码自主修改程序。
- `ou=Users,dc=lihuaio,dc=com` 用于员工内部管理，可以修改用户属性唯独不能修改用户密码，可以分发给人事进行员工管理。
- `uid=read,ou=Users,dc=lihuaio,dc=com` 用于外部系统接入登录认证用，只有读取权限，没有写权限。

### memberOf 避坑指南

- memberOf 用于通过用户 dn 查找用户的组。
- memberOf 是一种行为，在查询中必须显示指定查询 `memberOf` 字段。`memberOf` 字段不属于 dn 条目的属性。
- 使用 `slapadd` 指令导入 `ldif` 数据文件无法产生 `memberOf` 行为。因为该指令直接对数据库进行操作。
- `ldapadd` 可以使导入的 `ldif` 文件有 `memberOf` 属性，`ldapadd` 指令需要连接 `ldap` 服务器。
