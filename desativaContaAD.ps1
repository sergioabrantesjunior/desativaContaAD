# Prove: desativaContaAD.ps1
# Descricao Curta: Desativa conta, move OU e remove grupos
# Descrição Longa: Script que faz as funções informadas com base numa lista de arquivos de origem
#                  e presentes na variável $listaDeContas.
#                  Para cada usuário na lista faz:
#                  - Desabilita a conta
#                  - Move para OU de contas desabilitadas na variável $novaOU
#                  - Remove todos os grupos que a conta faz parte
# Frequencia: Sob demanda
# Autor: Sérgio Abrantes
# Contato: sergioabrantes@gmail.com
# Site: https://github.com/sergioabrantesjunior/desativaContaAD
# Licença: GPLv3
#
# VERSÃO:
# 1.0 26/09/2023: Versão inicial do script - Sérgio Abrantes

#
# Variáveis
#

# Lista de contas para desabilitar. Um por linha e no formato: "nome.sobrenome" sem @DOMINIO
$listaDeContas = Get-Content -Path C:\Temp\scripts\listContasZimbra.txt

# Caminho completo para a nova OU
$novaOU = OU=Contas Desabilitadas,OU=DOMINIO,DC=DOMINIO,DC=local


#
# Início
#

# Entra no diretório do script e importa funções de AD
cd C:\Temp\scripts ; cls ; $ErrorActionPreference = 'SilentlyContinue'

Import-Module ActiveDirectory


# Desabilita contas

# Desativa contas presentes na lista
foreach ($conta in $listaDeContas) {
    Disable-ADAccount -Identity $conta
    Write-Host "Conta $conta - desativada."
   
}


# Muda contas de OU para "OU=Contas Desabilitadas,OU=DOMINIO,DC=DOMINIO,DC=local"

 foreach ($conta in $listaDeContas) {

    # Retrieve DN of User.
    $UserDN = (Get-ADUser -Identity $listaDeContas).distinguishedName
    # Move user to target OU. 
    Move-ADObject -Identity $UserDN -TargetPath $novaOU
    Write-Host "Conta $listaDeContas - Movida de OU."

}


# Remove todos os grupos que o usuário faz parte

ForEach ($conta in $listaDeContas){

   $GROUPS = (Get-ADPrincipalGroupMembership -server ad0001 -Identity $conta).DistinguishedName
    
    if (($GROUPS).Count -gt 1){
        Get-ADPrincipalGroupMembership -server ad0001 -Identity $conta | ForEach {Remove-ADGroupMember -server ad0001 $_ -Members $conta -Confirm:$false}
        "Conta $conta - Removida dos grupos"
    }
}