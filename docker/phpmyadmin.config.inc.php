<?php
$cfg['PmaAbsoluteUri'] = '/phpmyadmin';
$cfg['PmaNoCookie_Enabled'] = false;
$cfg['LoginCookieStore'] = 0;
$cfg['LoginCookieDeleteAll'] = true;
$cookie_params = session_get_cookie_params();
$cookie_params['path'] = '/phpmyadmin/';
session_set_cookie_params($cookie_params);
