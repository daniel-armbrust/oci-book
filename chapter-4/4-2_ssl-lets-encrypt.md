# Capítulo 4: Melhorias na aplicação Wordpress

## 4.2 - HTTPS via Let’s Encrypt

### __Visão Geral__

_[Let’s Encrypt](https://letsencrypt.org/pt-br/)_ é uma organização sem fins lucrativos cuja missão é criar uma web mais segura e que respeita a privacidade do usuário, promovendo a adoção em larga escala do  _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_.

Por ser uma _[Autoridade Certificadora (CA - Certification Authority)](https://pt.wikipedia.org/wiki/Autoridade_de_certifica%C3%A7%C3%A3o)_ global, ela possibilita que pessoas e organizações do mundo todo obtenham, renovem e gerenciem _[certificados](https://pt.wikipedia.org/wiki/Certificado_digital)_ SSL/TLS de forma _**gratuita**_. Tais _[certificados](https://pt.wikipedia.org/wiki/Certificado_digital)_ podem ser usados por páginas web para habilitar conexões seguras através do protocolo _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_.

Visto isto, é possível afirmar que qualquer site agora pode adotar o _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ através do _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_. Todo navegador atual de hoje já confia nos certificados da _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_. 

>_**__NOTA:__** A [lista de compatibilidade](https://letsencrypt.org/pt-br/docs/certificate-compatibility/) pode ser acessada neste [link aqui](https://letsencrypt.org/pt-br/docs/certificate-compatibility/)._