# Capítulo 4: Primeira aplicação no OCI

## 4.1 - Fundamentos de Redes no OCI

### __Visão Geral da Rede no OCI__

Ao começar a trabalhar com o OCI, uma das primeiras etapas é a configuração da sua rede. o serviço de _[Networking do OCI](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/overview.htm)_ disponibiliza versões virtuais dos componentes de rede tradicionais no qual você pode usar para montar sua rede em cloud. Configurar a rede de dados é um pré-requisito para que você possa criar seus recursos.

Descrevo alguns dos componentes existentes no serviço de _[Networking do OCI](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/overview.htm)_ abaixo:

1. **VCN (Virtual Cloud Network)**
    - É uma rede virtual privada configurada nos data centers da Oracle e que reside em uma única região.
    - A partir de uma VCN criada e configurada, podemos criar subredes, máquinas virtuais, banco de dados, etc. É o nosso “tapete” para acomodarmos os móveis, a mesa, o sofá e a televisão.
    - Para criar uma VCN, você deve escolher um bloco de endereços IPv4 válido. A Oracle recomenda escolher um dos blocos documentados pela _[RFC1918](https://tools.ietf.org/html/rfc1918)_:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16

2. **SUB-REDES**
    - É a divisão de uma VCN em partes menores (subdivisões).
    - Cada sub-rede consiste em um intervalo contíguo de endereços IP (para IPv4 e IPv6, se ativado) que não se sobrepõem com outras sub-redes da VCN.    
    - Você pode criar uma subrede em um único _"domínio de disponibilidade"_ ou em uma região (subrede regional).
    - Recursos criados dentro de uma subrede utilizam a mesma tabela de roteamento, as mesmas listas de segurança (security lists), e mesmas opções de DHCP (dhcp options).
    - Você cria uma subrede como sendo pública ou privada. Uma subrede pública permite expor, através de IP público, um recurso na internet. A subrede privada, não.

![alt_text](./images/oci_arch1.jpeg  "OCI - Architecture #1")