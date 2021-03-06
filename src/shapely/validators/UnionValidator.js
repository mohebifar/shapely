// @flow

import createValidator from '../createValidator';
import type {Validator} from './Validator';
import type {ValidationResult} from './ValidationResult';

export default class UnionValidator {
  validators: Array<Validator>;

  constructor(variants: Array<mixed>) {
    this.validators = [];
    for (let variant of variants) {
      this.validators.push(createValidator(variant));
    }
  }

  isValid(val: mixed): boolean {
    for (let validator of this.validators) {
      if (validator.isValid(val)) return true;
    }
    return false;
  }

  getValidationResult(val: mixed): ValidationResult {
    if (this.isValid(val)) {
      return {
        isValid: 'true'
      }
    } else {
      const details = this._getValidationDetails(val);
      return {
        isValid: 'false',
        message:
          `Value doesn't match any of the expected variants.
Value: ${JSON.stringify(val)}
Details: \n${details.message}`,
        score: details.score
      }
    }
  }

  _getValidationDetails(val: mixed): {message: string, score: number} {
    var validationResults: Array<any> = [];
    for (let validator of this.validators) {
      validationResults.push(validator.getValidationResult(val));
    }

    validationResults.sort(function(a: any, b: any) {
      if (a.score < b.score) {
        return 1;
      } else if (a.score > b.score) {
        return -1;
      } else {
        return 0;
      }
    });

    if (validationResults.length > 3)
      validationResults.length = 3;

    const message = validationResults
      .map((v: any) => v.message)
      .join('\n');

    return {
      message: message,
      score: validationResults[0].score
    }
  }
}