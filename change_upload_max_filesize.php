<?php

// Carrega as configurações do banco de dados do GLPI
$configFile = '/var/www/html/config/config_db.php';

if (file_exists($configFile)) {
    $configContent = file_get_contents($configFile);

    preg_match("/'dbhost'\s*=>\s*'([^']+)/", $configContent, $matches);
    $dbhost = $matches[1] ?? '';

    preg_match("/'dbuser'\s*=>\s*'([^']+)/", $configContent, $matches);
    $dbuser = $matches[1] ?? '';

    preg_match("/'dbpassword'\s*=>\s*'([^']+)/", $configContent, $matches);
    $dbpassword = $matches[1] ?? '';

    preg_match("/'dbdefault'\s*=>\s*'([^']+)/", $configContent, $matches);
    $dbdefault = $matches[1] ?? '';

    // Obtém o valor atual do PHP
    $phpIniFile = '/etc/php/8.3/apache2/php.ini';
    $phpIniContent = file_get_contents($phpIniFile);

    preg_match("/upload_max_filesize\s*=\s*([^;]+)/", $phpIniContent, $matches);
    $uploadMaxSize = trim($matches[1]) ?? '';

    // Conecta ao banco de dados do GLPI
    $link = mysqli_connect($dbhost, $dbuser, $dbpassword, $dbdefault);

    if ($link === false) {
        die("ERROR: Could not connect. " . mysqli_connect_error());
    }

    // Atualiza o tamanho máximo de upload no banco de dados do GLPI
    $sql = "UPDATE glpi_configs SET value = '$uploadMaxSize' WHERE name = 'upload_max_filesize'";
    if (mysqli_query($link, $sql)) {
        echo "Tamanho máximo de upload atualizado com sucesso para: $uploadMaxSize";
    } else {
        echo "ERROR: Não foi possível executar $sql. " . mysqli_error($link);
    }

    mysqli_close($link);
} else {
    echo "Arquivo de configuração do banco de dados do GLPI não encontrado: $configFile";
}
?>
