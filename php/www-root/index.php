<?php
$extensions = get_loaded_extensions();
sort($extensions);

function formatBytes(int $bytes): string
{
    if ($bytes <= 0) {
        return '0 B';
    }

    $units = ['B', 'KB', 'MB', 'GB', 'TB'];

    $i = floor(log($bytes, 1024));
    $i = min($i, count($units) - 1);

    $divisor = pow(1024, $i);
    $value = round($bytes / $divisor, 2);

    return (string) $value . ' ' . $units[$i];
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MyPHP Application</title>
    <link rel="stylesheet" href="styles/style.css">
</head>
<body>

<header>
    <h1>MyPHP Application</h1>
</header>

<main>
    <section>
        <h2>Environment</h2>
        <ul>
            <li>PHP Version: <?= phpversion() ?></li>
            <li>Server API: <?= php_sapi_name() ?></li>
            <li>OS: <?= PHP_OS ?></li>
            <li>Hostname: <?= gethostname() ?></li>
        </ul>
    </section>

    <section>
        <h2>System Info</h2>
        <ul>
            <li>Memory Limit: <?= ini_get('memory_limit') ?></li>
            <li>Max Execution Time: <?= ini_get('max_execution_time') ?>s</li>
            <li>Upload Max Filesize: <?= ini_get('upload_max_filesize') ?></li>
            <li>Post Max Size: <?= ini_get('post_max_size') ?></li>
            <li>Disk Free Space: <?= formatBytes(disk_free_space('/')) ?></li>
        </ul>
    </section>

    <section>
        <h2>Loaded Extensions</h2>
        <div class="grid">
            <?php foreach ($extensions as $ext): ?>
                <div class="card"><?= htmlspecialchars($ext) ?></div>
            <?php endforeach; ?>
        </div>
    </section>

    <section>
        <h2>It runs on Nix, baby!</h2>
        <img src="https://brand.nixos.org/logos/nixos-logo-default-gradient-white-regular-vertical-recommended.svg"></img>
    </section>
</main>

<footer>
    <p>Generated at <?= date('Y-m-d H:i:s') ?></p>
</footer>

</body>
</html>
