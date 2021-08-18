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
    - Cada subrede consiste em um intervalo contíguo de endereços IP (para IPv4 e IPv6, se ativado) que não se sobrepõem com outras subredes da VCN.    
    - Você pode criar uma subrede em um único _"domínio de disponibilidade"_ ou em uma região (subrede regional - _modo recomendado_).
    - Recursos criados dentro de uma subrede utilizam a mesma tabela de roteamento (route table), as mesmas listas de segurança (security lists), e mesmas opções de DHCP (dhcp options).
    - Você cria uma subrede como sendo pública ou privada. Uma subrede pública permite expor, através de IP público, um recurso na internet. A subrede privada, não.

3. **Tabelas de Roteamento (route table)**
    - Contém regras de roteamento que direcionam o tráfego da subrede “para fora” da VCN.
    - Subredes dentro da mesma VCN, não precisam de regras de roteamento para se comunicarem.
    
4. **Regras de Segurança (security lists)** 
    - É o firewall da subrede.
    - É possível bloquear ou liberar o tráfego de rede por protocolos e portas.

5. **Opções de DHCP (dhcp options)**
    - São configurações informadas pelo protocolo DHCP a todos os recursos criados dentro de uma subrede. 
    - É possível definir, por exemplo, quais servidores DNS serão utilizados pelos recursos da subrede.

6. **Gateways de Comunicação**
    - Existem diferentes _"gateways de comunicação"_ que podem ser usados no OCI. Segue resumo: <br>
        - **Gateway de Internet (Internet Gateway)**
            - Possibilita comunicação direta vinda da internet. Para isto, é necessário que o recurso tenha um IP público.             
        - **Gateway NAT (NAT Gateway)**
            - Permite que recursos, sem endereço IP público, acessem a internet. Permite comunicação mas evita a exposição do recurso na internet.            
        - **Gateway de Serviço (Service Gateway)**
            - Possibilita que recursos de uma subrede se comuniquem com os serviços do OCI diretamente, sem utilizar a internet.            
        - **Gateway de Pareamento Local (Local Peering Gateway)**
            - Possibilita conectividade entre VCNs da mesma região.            
        - **Gateway de Roteamento Dinâmico (Dynamic Routing Gateway)**
            - Possibilita conectividade das suas VCNs com seu ambiente on-premises, através de VPN ou FastConnect (link dedicado).
     
![alt_text](./images/oci_arch1.jpeg  "OCI - Architecture #1")