<?php
/************************************************************************
 * This file is part of EspoCRM.
 * 
 * Modified for this HookedFormula extension.
 * (c) 2020 Hans Dijkema.
 * https://github.com/hdijkema/espocrm
 *
 * EspoCRM - Open Source CRM application.
 * Copyright (C) 2014-2020 Yuri Kuznetsov, Taras Machyshyn, Oleksiy Avramenko
 * Website: https://www.espocrm.com
 *
 * EspoCRM is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EspoCRM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with EspoCRM. If not, see http://www.gnu.org/licenses/.
 *
 * The interactive user interfaces in modified source and object code versions
 * of this program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU General Public License version 3.
 *
 * In accordance with Section 7(b) of the GNU General Public License version 3,
 * these Appropriate Legal Notices must retain the display of the "EspoCRM" word.
 ************************************************************************/

namespace Espo\Hooks\Common;

use Espo\ORM\Entity;
use Espo\Core\Utils\Util;

class Formula extends \Espo\Core\Hooks\Base
{
    public static $order = 11;

    protected function init()
    {
        $this->addDependency('metadata');
        $this->addDependency('formulaManager');
    }

    protected function getMetadata()
    {
        return $this->getInjection('metadata');
    }

    protected function getFormulaManager()
    {
        return $this->getInjection('formulaManager');
    }

    protected function getScript($script, $hook)
    {
	$hooks = [ 'afterSave', 'beforeRemove', 'afterRemove' ];
        if ($hook != 'beforeSave') { array_unshift($hooks, $hook); }

	$i = 0;
	$n = count($hooks);
        for($i = 0; $i < $n; $i++) {
           $h = $hooks[$i];
           $begin_needle = "begin:$h";
           $end_needle = "end:$h";
           $idx_begin = strpos($script, $begin_needle);
           $idx_end = strpos($script, $end_needle);
           if ($idx_begin === false || $idx_end === false) {
              if ($h == $hook) { return false; }
           } else {
              $idx = $idx_begin + strlen($begin_needle);
              $len = $idx_end - $idx;
              $part = substr($script, $idx, $len); 
              $script = substr($script, 0, $idx_begin) . substr($script, $idx_end + strlen($end_needle));
              if ($h == $hook) { return $part; }
           }
        }

        if ($hook == 'beforeSave') {
           // return what's left of $script
	   return $script;
        } 
    }

    protected function executeFormula(Entity $entity, array $options = array())
    {
        if (!empty($options['skipFormula'])) return;

	$hook = $options['hook'];

	if ($hook == 'beforeSave') {
            $scriptList = $this->getMetadata()->get(['formula', $entity->getEntityType(), 'beforeSaveScriptList'], []);
            $variables = (object)[];
            foreach ($scriptList as $script) {
                try {
                    $this->getFormulaManager()->run($script, $entity, $variables);
                } catch (\Exception $e) {
                    $GLOBALS['log']->error('Formula failed: ' . $e->getMessage());
                }
            }
        }

        $customScript = $this->getMetadata()->get(['formula', $entity->getEntityType(), 'beforeSaveCustomScript']);
        if ($customScript) {
	    $customScript = $this->getScript($customScript, $hook);
            if ($customScript) {
               try {
                   $this->getFormulaManager()->run($customScript, $entity, $variables);
               } catch (\Exception $e) {
                   $GLOBALS['log']->error('Formula failed: ' . $e->getMessage());
               }
            }
        }
    }

    public function beforeSave(Entity $entity, array $options = array())
    {
	$options['hook'] = 'beforeSave';
	$this->executeFormula($entity, $options);
    }

    public function afterSave(Entity $entity, array $options = array())
    {
	$options['hook'] = 'afterSave';
	$this->executeFormula($entity, $options);
    }

    public function beforeRemove(Entity $entity, array $options = array())
    {
	$options['hook'] = 'beforeRemove';
	$this->executeFormula($entity, $options);
    }

    public function afterRemove(Entity $entity, array $options = array())
    {
	$options['hook'] = 'afterRemove';
	$this->executeFormula($entity, $options);
    }
}

