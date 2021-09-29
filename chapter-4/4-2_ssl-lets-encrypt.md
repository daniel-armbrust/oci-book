# Capítulo 4: Melhorias na aplicação Wordpress

## 4.2 - HTTPS via Let’s Encrypt

### __Visão Geral__

A comunicação segura pela _[web](https://pt.wikipedia.org/wiki/World_Wide_Web)_ depende do _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_, que requer o uso de um _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_ que permite aos _[navegadores](https://pt.wikipedia.org/wiki/Navegador_web)_ verificar a identidade dos servidores da _[web](https://pt.wikipedia.org/wiki/World_Wide_Web)_. 

Uma _[Autoridade Certificadora (CA - Certification Authority)](https://pt.wikipedia.org/wiki/Autoridade_de_certifica%C3%A7%C3%A3o)_ é uma entidade responsável pela emissão dos _[certificados digitais](https://pt.wikipedia.org/wiki/Certificado_digital)_.

Já uma _[assinatura digital](https://pt.wikipedia.org/wiki/Assinatura_digital)_, contida em um _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_, possui a mesma validade jurídica de um documento autenticado em cartório. 

Visto isto, o único meio de um servidor existente na _[web](https://pt.wikipedia.org/wiki/World_Wide_Web)_ poder provar sua identidade, é através de um _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_ que foi emitido por uma _[autoridade certificadora](https://pt.wikipedia.org/wiki/Autoridade_de_certifica%C3%A7%C3%A3o)_ confiável. Através de um _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_ válido é que é possível confiar no site do seu banco, por exemplo.

_[Let’s Encrypt](https://letsencrypt.org/pt-br/)_ é uma organização sem fins lucrativos cuja missão é criar uma web mais segura e que respeita a privacidade do usuário, promovendo a adoção em larga escala do _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_.

Por ser uma _[autoridade certificadora](https://pt.wikipedia.org/wiki/Autoridade_de_certifica%C3%A7%C3%A3o)_ global, ela possibilita que pessoas e organizações do mundo todo obtenham, renovem e gerenciem _[certificados](https://pt.wikipedia.org/wiki/Certificado_digital)_ SSL/TLS de forma __gratuita__. Tais _[certificados](https://pt.wikipedia.org/wiki/Certificado_digital)_ podem ser usados por servidores da _[web](https://pt.wikipedia.org/wiki/World_Wide_Web)_ para habilitar conexões seguras através do protocolo _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_.

É possível afirmar que qualquer site agora, pode adotar o _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ através do _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_. Alem disto, todo navegador atual de hoje já _confia_ nos certificados emitidos pelo _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_. 

>_**__NOTA:__** A [lista de compatibilidade](https://letsencrypt.org/pt-br/docs/certificate-compatibility/) pode ser acessada neste [link aqui](https://letsencrypt.org/pt-br/docs/certificate-compatibility/)._

Existem outras _[autoridades certificadoras](https://pt.wikipedia.org/wiki/Autoridade_de_certifica%C3%A7%C3%A3o)_ disponíveis como a _[VeriSign](https://pt.wikipedia.org/wiki/VeriSign)_, _[Certisign](https://pt.wikipedia.org/wiki/Certisign)_ ou _[DigiCert](https://en.wikipedia.org/wiki/DigiCert)_, por exemplo. Porém são pagas!

Vamos começar pela instalação da ferramenta _[Certbot](https://certbot.eff.org/)_ e seguiremos até a emissão de um certificado digital válido para usarmos na aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_.

### __A ferramenta Certbot__

O _[Certbot](https://certbot.eff.org/)_ é uma ferramenta executada em _modo cliente_ e usada para obter _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_ do _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_.

Existem diversas formas para se instalar o _[Certbot](https://certbot.eff.org/)_. Sugiro consultar a _[página oficial](https://certbot.eff.org/instructions)_ neste _[link](https://certbot.eff.org/instructions)_ para um guia passo a passo, dependendo da configuração que você possui. O requisito principal é possuir o _[python](https://pt.wikipedia.org/wiki/Python)_ e seu _gerenciador de pacotes_ _[pip](https://pt.wikipedia.org/wiki/Pip_(gerenciador_de_pacotes))_ instalados em seu sistema operacional.

No meu caso, irei realizar a instalação do _[Certbot](https://certbot.eff.org/)_ dentro de um _[ambiente virtual python (venv)](https://virtualenv.pypa.io/en/latest/)_ através do _[pip](https://pt.wikipedia.org/wiki/Pip_(gerenciador_de_pacotes))_.

```
darmbrust@hoodwink:~$ python3 -m venv certbot-venv
darmbrust@hoodwink:~$ source certbot-venv/bin/activate
```

Uma vez dentro deste _[ambiente virtual](https://virtualenv.pypa.io/en/latest/)_, é possível instalar o _[Certbot](https://certbot.eff.org/)_:

```
(certbot-venv) darmbrust@hoodwink:~$ pip install --upgrade pip
(certbot-venv) darmbrust@hoodwink:~$ pip install --no-build-isolation certbot
```

>_**__NOTA:__** A ferramenta [Certbot](https://certbot.eff.org/) exige que algumas dependências referentes as bibliotecas do sistema operacional sejam satisfeitas antes da sua instalação. No meu caso, tive que instalar os pacotes libffi-dev, python3-dev e openssl-dev para que tudo ocorresse bem. Consulte a [página oficial](https://certbot.eff.org/docs/install.html#system-requirements) para saber detalhes referente ao seu sistema operacional._

```
(certbot-venv) darmbrust@hoodwink:~$ deactivate
darmbrust@hoodwink:~$ sudo ln -sf ~/certbot-venv/bin/certbot /usr/bin/certbot
darmbrust@hoodwink:~$ sudo certbot --version
certbot 1.19.0
```

### __Adquirindo um certificado via DNS challenge__

Uma das formas de se obter um _[certificado digital](https://pt.wikipedia.org/wiki/Certificado_digital)_ válido emitido pelo _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_, é através do chamado _"desafio DNS" (dns challenge)_. 

Para que o certificado seja emitido, você precisa demonstrar _controle_ sobre o seu _[domínio DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)_. Esta é uma das formas exigidas pelo _[Let’s Encrypt](https://letsencrypt.org/pt-br/)_, para que seja possível emitir um certificado.


```

```

>_**__NOTA:__** Existe um outro tipo de "desafio" que é via "http". Consulte a [documentação](https://certbot.eff.org/docs/using.html#getting-certificates-and-choosing-plugins) do [Certbot](https://certbot.eff.org/) neste [link aqui](https://certbot.eff.org/docs/using.html#getting-certificates-and-choosing-plugins) para saber mais sobre._