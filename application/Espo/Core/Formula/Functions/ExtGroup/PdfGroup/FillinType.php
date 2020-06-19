<?php
/************************************************************************
 * This file is part of EspoCRM.
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

namespace Espo\Core\Formula\Functions\ExtGroup\PdfGroup;

use Espo\Core\Exceptions\Error;
use mikehaertl\pdftk\Pdf

#
# arg1 - document-id
# arg2 - filename
# and arg2 .. n: field, value, etc. 
#

class FillinType extends \Espo\Core\Formula\Functions\Base
{
    protected function init()
    {
        $this->addDependency('entityManager');
        $this->addDependency('serviceFactory');
    }

    public function process(\StdClass $item)
    {
        $args = $this->fetchArguments($item);

        if (count($args) < 1) throw new Error("Formula ext\\pdf\\fillin: Too few arguments.");

	$document_id = shift $args;
	$filename = shift $args;

        $fields = [];
        while(array_count($args) > 0) {
            $field = shift $args;
            $value = shift $args;
            $fields[$field] = $value;
        }

        $em = $this->getInjection('entityManager');

        $document = $em->getEntity('Document', $document_id);

        if (!$document) {
            $GLOBALS['log']->warning("Formula ext\\pdf\\fillin: document {$document_id} does not exist.");
            return null;
        }

        if ($fileName) {
            if (substr($fileName, -4) !== '.pdf') {
                $fileName .= '.pdf';
            }
        } else {
            $GLOBALS['log']->warning("Formula ext\\pdf\\fillin: filename must be given.");
            return null;
        }

	$file_id = $document->get('file_id');
        $attachment = $this->getEntityManager()->getEntity('Attachment', $file_id);
        if (!$attachment) {
            $GLOBALS['log']->warning("Formula ext\\pdf\\fillin: filename not found.");
            return null;
        }

	$pdf_in_filename = $this->getEntityManager()->getRepository('Attachment')->getFilePath($attachment);
        $pdf_out_filename = "/tmp/$filename";

        $pdf = new Pdf($pdf_in_filename);
        $pdf->fillForm($fields);
        $pdf->needAppearances();
        $pdf->saveAs($pdf_out_filename);
        $contents = file_get_contents($pdf_out_filename);
        unlink($pdf_out_filename);

        $attachment = $em->createEntity('Attachment', [
            'name' => $fileName,
            'type' => 'application/pdf',
            'contents' => $contents,
            'relatedId' => $id,
            'relatedType' => $entityType,
            'role' => 'Attachment',
        ]);

        return $attachment->id;
    }
}
