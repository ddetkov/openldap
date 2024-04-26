# OpenLDAP Docker Image for Изделие №4 Detkov Pro.

OpenLDAP — открытая реализация LDAP, разработанная одноимённым проектом, распространяется под собственной свободной лицензией OpenLDAP Public License. В числе прочих есть реализации для различных модификаций BSD, а также Linux, AIX, HP-UX, macOS, Solaris, Windows и z/OS.
OpenLDAP состоит из трёх главных компонентов:
- slapd — независимый демон LDAP и соответствующие оверлеи и инструменты;
- библиотеки, реализующие протокол LDAP;
- утилиты, инструменты и вспомогательные клиенты.

This Docker image provides an OpenLDAP Server for testing LDAP applications, i.e. unit tests. The server is initialized with the example domain `eden.local` with data from the [Futurama Wiki][futuramawikia].

Parts of the image are based on the work from Nick Stenning [docker-slapd][slapd] and Bertrand Gouny [docker-openldap][openldap].

```

docker build . --file Dockerfile --tag detkovpro/openldap:latest
docker push detkovpro/openldap:latest

```


## Контроллер домена

DNS - Active Directory и Kubernetes в развертываниях больших кластеров

Централизованное управление несколькими доменами

Сложные операции с просмотром имен централизованно выполняются внутренней службой DNS. Это позволяет избежать сложного управления несколькими доменами в отдельных модулях pod и упрощает систему.

Отсутствие записей для внутренних модулей pod на внешних DNS-серверах

В результате этого принципа проектирования кластер больших данных не будет создавать записи A и PTR и управлять ими для модулей pod в пространстве IP-адресов Kubernetes на внешних DNS-серверах.

Отсутствие дублирования записей

Внутренние записи DNS находятся в нескольких местах. Единственным хранилищем для этих записей является Kubernetes CoreDNS. Внутренний CoreDNS в кластере больших данных выполняет вычислительное переопределение и перенаправление запросов DNS в Kubernetes CoreDNS.

Простота конфигураций pod

Так как только внутренний CoreDNS кластера больших данных указан в /etc/resolv.conf во всех модулях pod кластера больших данных, картина сети с точки зрения pod упрощается. Вся сложность скрыта во внутреннем CoreDNS.

Статический и надежный IP-адрес для службы DNS

Служба CoreDNS, которую развертывает кластер больших данных, будет иметь зарегистрированный статический внутренний IP-адрес, доступ к которому можно получить из всех модулей pod. Благодаря этому можно не обновлять значения в /etc/resolv.conf.

Управление балансировкой нагрузки службы поддерживается с помощью Kubernetes

Когда выполняется просмотр для служб, а не отдельных модулей pod, запросы по-прежнему направляются в Kubernetes CoreDNS, поэтому кластер больших данных не занимается реализацией балансировки нагрузки специально для домена AD.
Например, если поступает запрос прямого просмотра для compute-0-svc.contoso.local, он будет преобразован в compute-0-svc.contoso.svc.cluster.local. Этот запрос будет перенаправлен в Kubernetes CoreDNS, где и будет осуществляться балансировка нагрузки. Ответ будет представлять собой IP-адрес одного из нескольких экземпляров вычислительного пула (реплики pod).

Масштабируемость

Так как в кластере больших данных не хранятся никакие записи, внутренний CoreDNS кластера больших данных можно масштабировать без сохранения состояния и репликации записей между несколькими репликами. Если записи DNS будут храниться в кластере больших данных, репликация состояния по всем модулям pod также должна будет учитывать кластер больших данных.
Записи служб, доступные извне, остаются в AD DNS

Для конечных точек служб, которые должны быть доступны клиентам за пределами кластера Kubernetes, при развертывании кластера больших данных на DNS-сервере Active Directory будут созданы записи DNS. Пользователь будет вводить DNS-имена для регистрации в профилях конфигурации развертывания.

Автоматический отзыв

После удаления кластера больших данных не нужно выполнять дополнительные динамические задачи по удалению записей DNS при отзыве кластера. Единственными записями в удаленном DNS Active Directory, которые необходимо очистить, являются внешние службы, а их число статично. Внутренние DNS-записи будут автоматически удалены вместе с кластером.

The Flask extension [flask-ldapconn][flaskldapconn] use this image for unit tests.

[slapd]: https://github.com/nickstenning/docker-slapd
[openldap]: https://github.com/osixia/docker-openldap
[flaskldapconn]: https://github.com/rroemhild/flask-ldapconn
[futuramawikia]: http://futurama.wikia.com

## Features

* Initialized with data from Futurama
* Support for LDAP over TLS (STARTTLS) using a self-signed cert, or valid certificates (LetsEncrypt, etc)
* memberOf overlay support
* MS-AD style groups support
* Supports Forced STARTTLS 
* Supports custom domain and custom directory structure


## Usage

```
docker pull ghcr.io/ddetkov/openldap:master
docker run --rm -p 10389:10389 -p 10636:10636 ghcr.io/ddetkov/openldap:master
```

## Testing

```
# List all Users
ldapsearch -H ldap://localhost:10389 -x -b "ou=people,dc=eden,dc=local" -D "cn=admin,dc=eden,dc=local" -w GoodNewsEveryone "(objectClass=inetOrgPerson)"

# Request StartTLS
ldapsearch -H ldap://localhost:10389 -Z -x -b "ou=people,dc=dc=eden,dc=local" -D "cn=admin,dc=dc=eden,dc=local" -w GoodNewsEveryone "(objectClass=inetOrgPerson)"

# Enforce StartTLS
ldapsearch -H ldap://localhost:10389 -ZZ -x -b "ou=people,dc=dc=eden,dc=local" -D "cn=admin,dc=dc=eden,dc=local" -w GoodNewsEveryone "(objectClass=inetOrgPerson)"

# Enforce StartTLS with self-signed cert
LDAPTLS_REQCERT=never ldapsearch -H ldap://localhost:10389 -ZZ -x -b "ou=people,dc=dc=eden,dc=local" -D "cn=admin,dc=dc=eden,dc=local" -w GoodNewsEveryone "(objectClass=inetOrgPerson)"
```

## Exposed ports

* 10389 (ldap)
* 10636 (ldaps)

## Exposed volumes

* /etc/ldap/slapd.d
* /etc/ldap/ssl
* /var/lib/ldap
* /run/slapd


## LDAP structure

### dc=eden,dc=local

| Admin            | Secret           |
| ---------------- | ---------------- |
| cn=admin,dc=eden,dc=local | GoodNewsEveryone |

### ou=people,dc=eden,dc=local

#### cn=Hubert J. Farnsworth,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Hubert J. Farnsworth |
| sn               | Farnsworth |
| description      | Human |
| displayName      | Professor Farnsworth |
| employeeType     | Owner |
| employeeType     | Founder |
| givenName        | Hubert |
| jpegPhoto        | JPEG-Photo (630x507 Pixel, 26780 Bytes) |
| mail             | professor@planetexpress.com |
| mail             | hubert@planetexpress.com |
| ou               | Office Management |
| title            | Professor |
| uid              | professor |
| userPassword     | professor |


### cn=Philip J. Fry,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Philip J. Fry |
| sn               | Fry |
| description      | Human |
| displayName      | Fry |
| employeeType     | Delivery boy |
| givenName        | Philip |
| jpegPhoto        | JPEG-Photo (429x350 Pixel, 22132 Bytes) |
| mail             | fry@planetexpress.com |
| ou               | Delivering Crew |
| uid              | fry |
| userPassword     | fry |


### cn=John A. Zoidberg,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | John A. Zoidberg |
| sn               | Zoidberg |
| description      | Decapodian |
| displayName      | Zoidberg |
| employeeType     | Doctor |
| givenName        | John |
| jpegPhoto        | JPEG-Photo (343x280 Pixel, 26438 Bytes) |
| mail             | zoidberg@planetexpress.com |
| ou               | Staff |
| title            | Ph. D. |
| uid              | zoidberg |
| userPassword     | zoidberg |

### cn=Hermes Conrad,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Hermes Conrad |
| sn               | Conrad |
| description      | Human |
| employeeType     | Bureaucrat |
| employeeType     | Accountant |
| givenName        | Hermes |
| mail             | hermes@planetexpress.com |
| ou               | Office Management |
| uid              | hermes |
| userPassword     | hermes |

### cn=Turanga Leela,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Turanga Leela |
| sn               | Turanga |
| description      | Mutant |
| employeeType     | Captain |
| employeeType     | Pilot |
| givenName        | Leela |
| jpegPhoto        | JPEG-Photo (429x350 Pixel, 26526 Bytes) |
| mail             | leela@planetexpress.com |
| ou               | Delivering Crew |
| uid              | leela |
| userPassword     | leela |

### cn=Bender Bending Rodríguez,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Bender Bending Rodríguez |
| sn               | Rodríguez |
| description      | Robot |
| employeeType     | Ship's Robot |
| givenName        | Bender |
| jpegPhoto        | JPEG-Photo (436x570 Pixel, 26819 Bytes) |
| mail             | bender@planetexpress.com |
| ou               | Delivering Crew |
| uid              | bender |
| userPassword     | bender |

### cn=Amy Wong+sn=Kroker,ou=people,dc=eden,dc=local

Amy has a multi-valued DN

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | inetOrgPerson |
| cn               | Amy Wong |
| sn               | Kroker |
| description      | Human |
| givenName        | Amy |
| mail             | amy@planetexpress.com |
| ou               | Intern |
| uid              | amy |
| userPassword     | amy |

### cn=admin_staff,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | Group |
| cn               | admin_staff |
| member           | cn=Hubert J. Farnsworth,ou=people,dc=planetexpress,dc=com |
| member           | cn=Hermes Conrad,ou=people,dc=planetexpress,dc=com |

### cn=ship_crew,ou=people,dc=eden,dc=local

| Attribute        | Value            |
| ---------------- | ---------------- |
| objectClass      | Group |
| cn               | ship_crew |
| member           | cn=Turanga Leela,ou=people,dc=planetexpress,dc=com |
| member           | cn=Philip J. Fry,ou=people,dc=planetexpress,dc=com |
| member           | cn=Bender Bending Rodríguez,ou=people,dc=planetexpress,dc=com |


## JAAS configuration

In case you want to use this OpenLDAP server for testing with a Java-based
application using JAAS and the `LdapLoginModule`, here's a working configuration
file you can use to connect.

```
other {
  com.sun.security.auth.module.LdapLoginModule REQUIRED
    userProvider="ldap://localhost:10389/ou=people,dc=eden,dc=local"
    userFilter="(&(uid={USERNAME})(objectClass=inetOrgPerson))"
    useSSL=false
    java.naming.security.principal="cn=admin,dc=eden,dc=local"
    java.naming.security.credentials="GoodNewsEveryone"
    debug=true
    ;
};
```

This config uses the admin credentials to connect to the OpenLDAP server and to
submit the search query for the user that enters their credentials. As username
the `uid` attribute of each entry is used.
